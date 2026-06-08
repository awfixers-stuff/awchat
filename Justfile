# AWChat project tasks (see docs/DESIGN.md)

build:
    cd android && ./gradlew assembleDebug --no-daemon

test:
    cd android && ./gradlew testDebugUnitTest --no-daemon

# Git sync (master tracks origin/master; pull is fast-forward only)
pull:
    git pull --ff-only

push:
    git push