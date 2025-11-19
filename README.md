
# 1Password SSH + GitHub SSH Setup (Linux / Omarchy)

## 1. Enable the 1Password SSH agent

1. Open **1Password → Settings → Developer**  
2. Enable **“SSH Agent”**  
3. For each SSH key you want to use:
   - Open the item  
   - Enable **“Use with SSH”**

Your SSH agent socket will be available at:

```
~/.1password/agent.sock
```

---

## 2. Configure SSH to use the 1Password agent

Create or edit:

```
~/.ssh/config
```

Add:

```sshconfig
Host *
  IdentityAgent ~/.1password/agent.sock
  IdentitiesOnly no
```

Reload your shell:

```bash
exec "$SHELL" -l
```

Verify SSH sees your keys:

```bash
ssh-add -l
```

---

## 3. Add your 1Password public key(s) to GitHub

For **each** SSH key you want to use with GitHub:

1. In 1Password → open the key item  
2. Click “Copy Public Key”  
3. Go to GitHub → Settings → SSH and GPG Keys  
4. Click “New SSH key”  
5. Paste the public key  

---

## 4. Test SSH → GitHub authentication

Run:

```bash
ssh -T git@github.com
```

Expected:

```
Hi <username>! You've successfully authenticated...
```

---

## 5. Configure GitHub CLI (`gh`) to use SSH

Run:

```bash
gh auth login
```

Choose:

- GitHub.com  
- SSH as the preferred protocol  
- When prompted to generate a new SSH key: choose **n**  

Follow the browser OAuth login.

Verify:

```bash
gh auth status
```

---

## 6. Confirm Git operations use SSH + 1Password

Clone a repo:

```bash
gh repo clone <your-username>/<repo>
```

Or test:

```bash
git fetch
```

---

## Short Summary

1. Enable SSH agent in 1Password  
2. Add IdentityAgent config  
3. Add public keys to GitHub  
4. Test ssh -T  
5. gh auth login (SSH, no new key)  
6. Git/gh now use 1Password-managed keys


---

# Clam AV

## Install & configure everything
make install

## Check status
make status

## Trigger a manual periodic scan
make scan-now

## View logs
make logs

## Edit which paths get scanned daily
make edit-config

## Completely remove it again
make uninstall
