Plugin used to get a listing of forum posts for search indexing

# Running Discourse locally

1. clone https://github.com/discourse/discourse
2. Modify bin/docker/boot_dev, on the line that starts with `docker run -d -p 1080:1080 -p 3000:3000`, add a volume mapping to your local path `-v /Users/kevin.glinski/code/src/bitbucket.org/inindca/developer-forum/src/search:/src/plugins/genesyscloudsearch` full example `docker run -d -p 1080:1080 -p 3000:3000 -v /Users/kevin.glinski/code/src/bitbucket.org/inindca/developer-forum/src/search:/src/plugins/genesyscloudsearch -v "$DATA_DIR:/shared/postgres_data:delegated" -v "$SOURCE_DIR:/src:delegated" --hostname=discourse --name=discourse_dev --restart=always discourse/discourse_dev:release /sbin/boot`

3. from the discourse directory, run `./bin/docker/boot_dev`
4. from the discourse directory, run `./bin/docker/rails s`
