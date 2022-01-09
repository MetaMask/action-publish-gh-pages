# MetaMask/action-publish-gh-pages

This repository can be used on its own but is better used along with: https://github.com/MetaMask/action-publish-release

Add the following Workflow File to your repository in the path `.github/workflows/publish-gh-pages.yml`

## Usage

This action makes a few assumptions:

- The package using this action is using `yarn`
- The package requires some build command to be run before being published
- No commands other than the build command are required before publishing
- The GitHub Pages branch name is `gh-pages`

Every input has useful defaults, and can freely be set to whatever matches your preferences.
The notable exception is `destination-directory`, which defaults to `'.'`.
If this default is left in place, the contents of the `gh-pages` branch will be overwritten with the contents of `source-directory`.
If `destination-directory` is set to anything other than `'.'`, the contents of `source-directory` will be committed to the specified destination directory without affecting any content outside of that directory.

### Example Workflow

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
      - uses: MetaMask/action-publish-gh-pages@v2
        with:
          source-directory: public
          # This will commit the contents of "public" in the source branch to
          # a directory named "latest" on the gh-pages branch.
          # If destination-directory were omitted, all existing content of the
          # gh-pages branch would be deleted and the the contents of "public"
          # would be committed to the root directory.
          destination-directory: latest
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```
