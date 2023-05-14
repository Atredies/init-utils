COPY . . 
RUN if ! npm run eslint; then \ 
        npm run eslint --fix && \
        git config user.name 'lint bot' && \
        git config user.email 'lint@bot.com' && \
        git add -A &&
        git commit -m 'Automatically linted' && \
        git checkout -b $(git branch --show-current)-linted && \
        git push -f origin $(git branch --show-current)-linted; && \
        echo 'line failed!'; exit 1; \
    fi