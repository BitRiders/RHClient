using RHClient
using Logging

host = "localhost"
port = "5000"

if ("RH_HOST" in keys(ENV))
    host = ENV["RH_HOST"]
end
if ("RH_PORT" in keys(ENV))
    port = ENV["RH_PORT"]
end

c = RHClient.rhClient("http://$(host):$(port)")
test_header = Dict{String, String}("Expires" => "Wed, 21 Oct 2015 07:28:00 GMT")

function test_create_path()
    @info "Starting createPath() test."
    RHClient.createPath(c, "/test", 200, "test")
    RHClient.createPath(c, "/test1", 200, "test1"; delay=3)
    RHClient.createPath(c, "/test2", 200, "test2"; headers=test_header)

    try
        RHClient.createPath(c, 200, 200, "Int path test")
    catch e
        @info "Attempted to create path with integer path type.
        Creation failed; path name must be of type String"
    end
    
    try
        RHClient.createPath(c, nothing, 200, "nothing path test")
    catch e
        @info "Attempted to create path with nothing path type.
        Creation failed; path name must be of type String"
    end

    RHClient.deletePath(c, "/test")
    RHClient.deletePath(c, "/test1")
    RHClient.deletePath(c, "/test2")

    @info "Finished testing.
    "
end

function test_create_paths()
    @info "Starting createPaths() test."

    path_lst = [Dict{String, Any}("path" => "/test", "rc" => 200, "return_value" => "test"),
                Dict{String, Any}("path" => "/test1", "rc" => 200, "return_value" => "test1", "delay" => 2),
                Dict{String, Any}("path" => "/test2", "rc" => 200, "return_value" => "test2", "headers" => test_header),
                Dict{String, Any}("path" => "/test3", "rc" => 200, "return_value" => "test3", "delay" => 2, "headers" => test_header)
    ]
    RHClient.createPaths(c, path_lst)
    RHClient.deletePaths(c, ["/test", "/test1", "/test2", "/test3"])

    @info "Finished testing.
    "
end

function test_update_paths()
    @info "Starting updatePath() test."

    RHClient.createPath(c, "/test", 200, "test")
    RHClient.updatePath(c, "/test", 200, "updated test", delay=2, headers=test_header)
    RHClient.deletePath(c, "/test")

    @info "Finished testing.
    "
end

function test_get()
    @info "Starting getPath()/getAll() test."

    path_lst = [Dict{String, Any}("path" => "/test", "rc" => 200, "return_value" => "test"),
                Dict{String, Any}("path" => "/test1", "rc" => 200, "return_value" => "test1", "delay" => 5),
                Dict{String, Any}("path" => "/test2", "rc" => 200, "return_value" => "test2", "headers" => test_header),
                Dict{String, Any}("path" => "/test3", "rc" => 200, "return_value" => "test3", "delay" => 5, "headers" => test_header)
    ]
    RHClient.createPaths(c, path_lst)

    pathData1 = RHClient.getPath(c, "/test")
    pathData2 = RHClient.getPath(c, "/test1")
    pathsData = RHClient.getAll(c)

    @info "Returned the following data:
    $(pathData1)

    $(pathData2)

    $(pathsData)"

    RHClient.deletePaths(c, ["/test", "/test1", "/test2", "/test3"])

    @info "Finished Testing.
    "
end

function main()
    test_create_path()
    sleep(1)
    test_create_paths()
    sleep(1)
    test_update_paths()
    sleep(1)
    test_get()
end

main()
