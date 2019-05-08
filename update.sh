#！ /bin/bash

cd docker-vlmcsd

OLD_VERSION=`cat Dockerfile | grep "ENV VERSION" | cut -d  " " -f 3`
NEW_VERSION=`curl https://github.com/Wind4/vlmcsd/tags | grep '<a href="/Wind4/vlmcsd/releases/tag/' | cut -d '"' -f 2 | cut -d '/' -f 6 | head -1`

if [ "$OLD_VERSION" == "$NEW_VERSION" ]; then
    exit 0
else
    echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
    sed -i "s#^\s*ENV VERSION.*#ENV VERSION $NEW_VERSION#g" Dockerfile
    docker pull alpine:latest
    docker build -t "$DOCKER_USERNAME"/vlmcsd:$NEW_VERSION .
    docker push "$DOCKER_USERNAME"/vlmcsd
    git commit -am "vlmcsd $NEW_VERSION" || exit 0
    git push "https://${GH_TOKEN}@${GH_REF}" tags:tags
fi
