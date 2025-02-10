# Managing Environments with uv

The tool uv is a drop-in replacement for core Python packaging tools, written in the Rust programming language. It offers order-of-magni- tude performance improvements over the Python tools it replaces, in a single static binary without dependencies. While its uv venv and uv pip subcommands aim for compatibility with virtualenv and pip, uv also embraces evolving best practices, such as operating in a vir- tual environment by default.

By default, uv creates a virtual environment using the well-known name .venv (you can pass another location as an argument):
```sh
uv venv
```

Specify the interpreter for the virtual environment using the -- python option with a specification like 3.12 or python3.12 ; a full path to an interpreter also works. Uv discovers available interpreters by scanning your PATH. On Windows, it also inspects the output of py -- lists-paths. If you don’t specify an interpreter, uv defaults to python3 on Linux and macOS, and python.exe on Windows.

Despite its name, uv venv emulates the Python tool virtualenv, not the built-in venv module. Virtualenv creates environments with any Python interpreter on your system. It combines interpreter discovery with aggressive caching to make this fast and flawless.

By default, uv installs packages into the environment named .venv in the current directory or one of its parent directories (using the same logic as the Python Launcher for Unix):
```sh
uv pip install httpx
```

 It will never install or uninstall packages from your global environment unless you explicitly ask it to do so using the --system option.

 While uv’s initial development has focused on providing drop-in replacements for standard Python tooling, its ultimate goal is to grow into that one unified packaging tool that has eluded Python for so long—with the kind of developer experience that Rust developers love about Cargo.

run uv rather than pip for your app level dependencies. For example:
```sh
RUN uv pip install -r requirements.txt
# These packages do have their versions pinned, but mostly overlap with latest because I'm not a monster.
```

First run this in the same folder as compose.yml:
```sh
docker compose build
```

Then run:
```sh
docker compose up
```

As a reminder, in production, you want the following properties from your Docker workflow:
- Multi-stage builds, so you don’t ship your build tools.
- Judicious layering, for fast builds. Layers should be added in the inverse order they are likely to change so they can be cached for as long as possible.
- This also means that dependency installations (what’s in uv.lock) and application installations (what you wrote) should be strictly separate. If you’re doing something remotely akin to continuous deployment, your code is more likely to change than your dependencies.
- Bonus: build-cache mounts, so, for example, you don’t have to rebuild all wheels whenever your dependency layer needs to be recreated because one package needs an update.
- Bonus: byte-compile your Python files for faster container startup times.

What I like to do is to build a virtual environment with my application in the /app directory and then copy it wholesale into the runtime container. This has many upsides, including using the same base containers for different Python versions and virtualenvs coming with standard UNIX directories like bin or lib, making them natural application containers.

 # References

- [Docker images using uv's python](https://mkennedy.codes/posts/python-docker-images-using-uv-s-new-python-features/)
- [Production-ready Python Docker Containers with uv](https://hynek.me/articles/docker-uv/)
- [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
- [Why I Still Use Python Virtual Environments in Docker](https://hynek.me/articles/docker-virtualenv/)
- [Using Alpine can make Python Docker builds 50× slower](https://pythonspeed.com/articles/alpine-docker-python/)