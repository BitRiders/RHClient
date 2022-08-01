module RHClient

### including dependancies ###
using HTTP
using JSON
using Logging

### defining client struct ###
@doc """
    rhClient(url::String)

Constructor for the REST Harness client

# Arguments
- `url::String`: concatenation of REST Harness IP + Port
"""
struct rhClient
    url::String
end

### method definitions ###
@doc """
    create_path(c::rhClient, path::String, rc::Int64, return_value::String; 
        delay::Int64=0, headers::Any=nothing)

Send a "POST" HTTP request with a specified endpoint configuration to the REST Harness server.

# Arguments
- `path::String`: the name of the endpoint.
- `rc::Int64`: the return code used by REST Harness when the endpoint is accessed.
- `return_value::String`: the content of the endpoint.
- `delay::Int64=0`: number of seconds REST Harness waits before returning a response to a 
    "GET" request.
- `headers::Any=nothing`: A dictionary containing headers to send with the "POST" request.
"""
function create_path(c::rhClient, path::String, rc::Int64, return_value::String; 
        delay::Int64=0, headers::Any=nothing)

    # creating default header
    Content_header = Dict{String, String}("Content-Type" => "application/json")
    if headers !== nothing
        # checking for invalid data type
        if typeof(headers) != Dict{String, String}
            @warn "headers need to be type Dict{String, String}"
            throw(TypeError)
        end
        # updating headers if valid argument given
        headers_data = merge(Content_header, headers)
    else
        headers_data = Content_header
    end

    # generating path info
    path_configuration = Dict(
        "path" => path,
        "rc" => rc,
        "return_value" => return_value,
        "delay" => delay,
        "headers" => headers_data
    )

    # attempting HTTP request
    try
        result = HTTP.post(c.url, headers_data, JSON.json(path_configuration); 
        status_exception=true)
        @info "
    Successfully created the following endpoint:
    $(JSON.json(path_configuration))" 
    catch e
        @warn "Path creation failed!
        $(e)"
    end
end

@doc """
    create_paths(c::rhClient, path::Vector{Dict{String, Any}})

Send a "POST" HTTP request with a collection of endpoint configurations to the REST Harness 
    server.
    
# Arguments
- `path::Vector{Dict{String, Any}}`: a collection of endpoint configuraions.
"""
function create_paths(c::rhClient, path::Vector{Dict{String, Any}})

    for obj in path
        # verifying valid delay
        if !("delay" in keys(obj))
            obj["delay"] = 0
        elseif typeof(obj["delay"]) != Int64
            @warn "delay must be of type Int64"
            throw(TypeError)
        end

        # veriifying valid headers
        global headers_data = Dict{String, String}()
        Content_header = Dict{String, String}("Content-Type" => "application/json")
        if !("headers" in keys(obj))
            obj["headers"] = Content_header
            headers_data = obj["headers"]
        else
            if typeof(obj["headers"]) != Dict{String, String}
                throw(TypeError)
            end
            obj["headers"] = merge(Content_header, obj["headers"])
            headers_data = obj["headers"]
        
        end

        # sending request
        try
            result = HTTP.post(c.url, headers_data, JSON.json(obj); status_exception=true)
            @info "
    Successfully created the following endpoint:
    $(JSON.json(obj))"
        catch e
            @warn "Path creation failed!
            $(e)"
        end
    end
end

@doc """
    get_path(c::rhClient, path::String)

Send a "GET" HTTP request to the REST Harness server and retrieve the endpoint configuration.

Return endpoint configuration as a dictionary with `path` as the key and a dictionary of all 
    other configurations as the value.

# Arguments
- `path::String`: the name of the endpoint.
"""
function get_path(c::rhClient, path::String)
    try
        # retieve json data from flask server
        strData = String(HTTP.get(c.url).body)
        data = JSON.parse(strData)
        # checks for and implements delay
        if "delay" in keys(data[path])
            sleep(abs(data[path]["delay"]))
        end
        # return data as a log and as a value
        @info "
    $(path) : $(data[path])"
        return data[path]
    catch e
        @warn "$(path) doesn't exist.
        $(e)"
    end
end

@doc """
    get_all(c::rhClient)

Send a "GET" HTTP request to the REST Harness server and retrieve all of the currently 
    stored endpoint configurations.

Return the endpoint configurations as a dictionary with `path` as the keys and a dictionary of
    the all other configurations as the values.
"""
function get_all(c::rhClient)
    try
        # retrieving data from flask server
        strData = String(HTTP.get(c.url).body)
        data = JSON.parse(strData)
        return data
    catch e
        @warn "Could not retrieve data from server.
        $(e)"
    end
end

@doc """
    update_path(c::rhClient, path::String, rc::Int64, return_value::String; 
        delay::Int64=0, headers=nothing)

Send a specified endpoint configuration to the REST Harness server to update an existing endpoint.

# Arguments
- `path::String`: the name of the endpoint.
- `rc::Int64`: the return code used by REST Harness when the endpoint is accessed.
- `return_value::String`: the content of the endpoint.
- `delay::Int64=0`: number of seconds REST Harness waits before returning a response to a 
    "GET" request.
- `headers::Any=nothing`: A dictionary containing headers to send with the "POST" request.
"""
function update_path(c::rhClient, path::String, rc::Int64, return_value::String; 
        delay::Int64=0, headers=nothing)
    @info "Updating endpoint."
    createPath(c, path, rc, return_value; delay, headers)
    @info "Endpoint updated."
end

@doc """
    delete_path(c::rhClient, path::String)

Send a "DELETE" HTTP request with an endpoint name specified to delete it from the REST Harness
    server.

# Arguments
- `path::String`: the name of the endpoint.
"""
function delete_path(c::rhClient, path::String)
    try
        HTTP.request("DELETE", c.url, 
            Dict{String, String}("Content-Type" => "application/json"), 
            JSON.json(Dict{String, String}("path" => path)))
        @info "Endpoint $(path) deleted."
    catch e
        @warn "No endpoint match.
        Tried to delete $(path)
        $(e)"
    end
end

@doc """
    delete_paths(c::rhClient, path::String)

Send a "DELETE" HTTP request to delete all endpoint configurations from the REST Harness 
    server.

# Arguments
- `path::Vector{Dict{String, Any}}`: a collection of endpoint configuraions.
"""
function delete_paths(c::rhClient, paths::Any)
    @info "
    Paths sent to be deleted:
    $(paths)"
    try
        HTTP.request("DELETE", c.url, 
            Dict{String, String}("Content-Type" => "application/json"), JSON.json(paths))
        @info "All paths successfully deleted."
    catch e
        @warn "One or more paths do not exist!
        $(e)"
    end
end

### initializing methods for the rh client ###
url(c::rhClient) = c.url

createPath(c::rhClient, path::String, rc::Int64, return_value::String; delay::Int64=0, 
    headers::Any=nothing) = create_path(c, path, rc, return_value; delay, headers)

createPaths(c::rhClient, path::Vector{Dict{String, Any}}) = create_paths(c, path)

getPath(c::rhClient, path::String) = get_path(c, path)

getAll(c::rhClient) = get_all(c)

updatePath(c::rhClient, path::String, rc::Int64, return_value::String; delay::Int64=0, 
    headers::Any=nothing) = update_path(c, path, rc, return_value; delay, headers)

deletePath(c::rhClient, path::String) = delete_path(c, path)

deletePaths(c::rhClient, paths::Any) = delete_paths(c, paths)

end