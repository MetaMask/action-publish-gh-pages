# MetaMask/action-publish-gh-pages

This repository can be used on its own but is better used along with: https://github.com/MetaMask/action-publish-release

Add the following Workflow File to your repository in the path `.github/workflows/publish-gh-pages.yml`

## Usage

This action makes a few assumptions:

- the package using this action is using `yarn`
- the package has a command called `build`
- `build` should be run before publishing
- no other commands are required before publishing
- the repository has no existing `gh-pages` branch
- the branch used is `gh-pages`
- the `directory` given must not exist before `build`


```yml
name: Publish Github Pages

on:
  pull_request:
    types: [closed]

jobs:
  publish-gh-pages:
    permissions:
      contents: write
    # The second argument to startsWith() must match the release-branch-prefix
    # input to this Action. Here, we use the default, "release/".
    if: |
      github.event.pull_request.merged == true &&
      startsWith(github.event.pull_request.head.ref, 'release/')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Get Node.js version
        id: nvm
        run: echo ::set-output name=NODE_VERSION::$(cat .nvmrc)
      - uses: actions/setup-node@v2
        with:
          node-version: ${{ steps.nvm.outputs.NODE_VERSION }}
      - uses: MetaMask/action-publish-gh-pages@v1
        with:
          npm-build-command: build
          directory: public
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
