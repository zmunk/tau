# Setup
Creating docker image
```bash
docker build -t pi-sandbox -f Dockerfile .
```
Add to ~/.bashrc:
```bash
export PI_HOME="<path-to-this-repo>" # without trailing slash
alias pi-hunk="$PI_HOME/pi-hunk-wrapper"
alias pi-raw="$PI_HOME/pi-raw-wrapper"
alias tfs="$PI_HOME/user-scripts/tfs"
```
Copy skill
```bash
mkdir -p "$HOME/.pi/agent/skills"
cp -R -- "$PI_HOME/skills/hunk-review" "$HOME/.pi/agent/skills/"
```
Install hunk v0.20
```
npm i -g hunkdiff@0.20.1
```

# Running pi
```bash
pi-hunk
```

# Test
- Run pi
  - run `!hunk` inside of pi
- Run tfs
  - clone a repo that has an open PR and run TFS import
  - launch hunk
  - `tfs import` - imoprt PR comments into hunk
  - ask pi if it can see the hunk comments
