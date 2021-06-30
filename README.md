# MetaMask/action-publish-gh-pages

This repository can be used on its own but is better used along with: https://github.com/MetaMask/action-publish-release


Add the following Workflow File to your repository in the path `.github/workflows/publish-gh-pages.yml`


```yml
name: Publish Github Pages

jobs:
    publish-gh-pages:
        if: |
          github.event.pull_request.merged == true &&
          startsWith(github.event.pull_request.head.ref, 'release/')
        runs-on: ubuntu-latest
        steps:
            - uses: actions/checkout@v2
              with:
                  # This is to guarantee that the most recent tag is fetched.
                  # This can be configured to a more reasonable value by consumers.
                  fetch-depth: 0
            - name: Get Node.js version
              id: nvm
              run: echo ::set-output name=NODE_VERSION::$(cat .nvmrc)
            - uses: actions/setup-node@v2
              with:
                  node-version: ${{ steps.nvm.outputs.NODE_VERSION }}
            - uses: MetaMask/action-publish-gh-pages@v1
              with: 
                directory: public
              env:
                  GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

```
