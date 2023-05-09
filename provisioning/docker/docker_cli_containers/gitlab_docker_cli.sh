# This is a down and dirty way of starting a fast instance of gitlab
# Update --hostname variable and the HTTPS://URL.COM string

sudo docker run --detach \
--hostname grandhub.duckdns.org \
--env GITLAB_OMNIBUS_CONFIG="external_url 'HTTPS://URL.COM'" \
--publish 443:443 --publish 80:80 --publish 4567:4567 --publish 22:22 \
--name gitlab \
--restart always \
--volume $HOME/gitlab/config:/etc/gitlab \
--volume $HOME/gitlab/logs:/var/log/gitlab \
--volume $HOME/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce:latest