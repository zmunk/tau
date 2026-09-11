# Setup
Creating docker image
```bash
docker build -t pi-sandbox -f Dockerfile .
```
Add to ~/.bashrc:
```bash
export PI_HOME=<path-to-this-repo>
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
"$PI_HOME/pi-wrapper"
```

# Test
- Run pi
  - run `!hunk` inside of pi
- Run tfs
  - clone a repo that has an open PR and run TFS import
  - `"$PI_HOME/user-scripts/tfs"`
