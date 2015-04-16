Setup
=====
```
cd my/project/repo
mkdir tools && cd tools
git clone https://github.com/UCB-Republic/Gitlet-build.git build
cd ..
ln -sT tools/build/make.zsh make.zsh
```

Basic Usage
===========
```
cd my/project/repo
./make.zsh          # default target is build
./make.zsh build    # compile and package
./make.zsh clean    # clean up build products
```

Advanced Usage
==============
```
# Check that all files compile regardless of whether or not they're currently
# needed.
./make.zsh check

# Prepare working directory for submission (does not really submit)
# This target ensures that all auto-generated files are generated.
./make.zsh submit
```

