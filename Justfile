# AWChat project tasks (see docs/DESIGN.md)

build:
    ./gradlew assembleDebug --no-daemon

test:
    ./gradlew testDebugUnitTest --no-daemon

# Git sync (master tracks origin/master; pull is fast-forward only)
pull:
    git pull --ff-only

push:
    git push