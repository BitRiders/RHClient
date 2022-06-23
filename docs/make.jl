using RHClient
using Documenter

DocMeta.setdocmeta!(RHClient, :DocTestSetup, :(using RHClient); recursive=true)

makedocs(;
    modules=[RHClient],
    authors="Chris Saenz <chrissaenz@psg-inc.net> and contributors",
    repo="https://gitlab.com/my-username/RHClient.jl/blob/{commit}{path}#{line}",
    sitename="RHClient.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://my-username.gitlab.io/RHClient.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)
