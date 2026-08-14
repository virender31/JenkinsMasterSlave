# Jenkins Master-Slave Setup (Mac Host)

Architecture: **Jenkins Master** (Docker) + **Node A - Linux** (Docker SSH agent) + **Node B - Mac** (your native machine, JNLP agent).

- Build stage → runs on Node A (Linux)
- Test stage → runs on Node B (Mac, real host OS)

---

## 0. Prerequisites

- Docker Desktop for Mac installed and running
- Java 11+ installed on your Mac (`java -version`) — needed for the Mac agent
- Git installed
- A GitHub repo containing this project (push these files there first)

---

## 1. Generate an SSH key pair (for Node A - Linux agent)

```bash
ssh-keygen -t rsa -b 4096 -f ./jenkins_agent_key -N ""
```

This creates `jenkins_agent_key` (private) and `jenkins_agent_key.pub` (public).

Export the public key as an environment variable so docker-compose can inject it:

```bash
export SSH_PUBKEY=$(cat jenkins_agent_key.pub)
```

---

## 2. Start Jenkins Master + Linux Agent

```bash
docker compose up -d --build
```

Check both containers are running:

```bash
docker ps
```

---

## 3. Unlock Jenkins

```bash
docker exec jenkins-master cat /var/jenkins_home/secrets/initialAdminPassword
```

Open `http://localhost:8080`, paste the password, choose **Install suggested plugins**.

Then go to **Manage Jenkins → Plugins** and additionally install:
- Pipeline
- SSH Build Agents
- Blue Ocean (for the visual pipeline view)

---

## 4. Add Node A (Linux) in Jenkins

**Manage Jenkins → Nodes → New Node**
- Name: `linux-node`, type: Permanent Agent
- Remote root directory: `/home/jenkins/agent`
- Labels: `linux-node`
- Launch method: **Launch agents via SSH**
- Host: `linux-agent` (the Docker service name — reachable via the shared `jenkins-net` network)
- Credentials: **Add → SSH Username with private key**
  - Username: `jenkins`
  - Private key: paste contents of `jenkins_agent_key`
- Host Key Verification Strategy: "Non verifying" (fine for local demo)

Save, then confirm the node shows as online.

---

## 5. Add Node B (your Mac) as a JNLP agent

**Manage Jenkins → Nodes → New Node**
- Name: `mac-node`, type: Permanent Agent
- Remote root directory: e.g. `/Users/<you>/jenkins-agent`
- Labels: `mac-node`
- Launch method: **Launch agent by connecting it to the controller (Inbound/JNLP)**

Save. Jenkins will show a command + a download link for `agent.jar`. On your Mac:

```bash
mkdir -p ~/jenkins-agent && cd ~/jenkins-agent
curl -sO http://localhost:8080/jnlpJars/agent.jar
java -jar agent.jar -url http://localhost:8080/ -secret <SECRET_FROM_UI> -name "mac-node" -workDir "/Users/<you>/jenkins-agent"
```

Leave this running in a terminal tab — it connects your Mac as a live build node. Confirm it shows online in **Manage Nodes**.

---

## 6. Create the Pipeline job

**New Item → Pipeline** (name it e.g. `jenkins-master-slave-demo`)
- Under **Pipeline**, choose **Pipeline script from SCM**
- SCM: Git → paste your GitHub repo URL
- Script Path: `Jenkinsfile`

Save.

---

## 7. Run it

Click **Build Now**. Open **Blue Ocean** for a visual view of the two stages running on two different nodes.

You should see in the console log:
- `Build` stage log showing `hostname` = the Linux container
- `Test` stage log showing `hostname` = your Mac

---

## 8. What to capture for your submission

- Screenshot of **Manage Nodes** showing `linux-node` and `mac-node` both online
- Screenshot of the Blue Ocean pipeline graph (two stages, two nodes)
- Console output showing different hostnames per stage
- Your `Jenkinsfile` and repo link
- A short paragraph explaining `stash`/`unstash` — why it's needed (agents don't share a filesystem) — this is a good viva/report talking point

---

## Cleanup

```bash
docker compose down -v
```

And stop the `java -jar agent.jar` process on your Mac (Ctrl+C).