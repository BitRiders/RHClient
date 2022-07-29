using RHClient
using Documenter

push!(LOAD_PATH,"../src/")

DocMeta.setdocmeta!(RHClient, :DocTestSetup, :(using RHClient); recursive=true)

makedocs(;
    modules=[RHClient],
    authors="Chris Saenz <chrissaenz@psg-inc.net> and contributors",
    sitename="RHClient.jl Documentation",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://my-username.gitlab.io/RHClient.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md"
    ],
)
