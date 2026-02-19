# SESSION DAVID — Plan de Synchronisation Réelle
> Créé: 2026-02-19 | Status: À EXÉCUTER DEMAIN
> [NOVA:20260219-0200] | [H] = session terminée, handover actif

---

## PROBLÈME ACTUEL
Le site `session-david.vercel.app` est quasi-vide.
Les vrais logs sont sur le Mac mais **pas synchronisés** vers `docs/agents/`.

**Ce qui manque :**
- Les vrais logs de runner (`DREAMNOVA_MISSION_CONTROL/logs/runner-main.log`)
- L'état réel de MemuBot (122 tâches, queue OPUS_QUEUE.md)
- Les rapports superviseur (supervisor.log)
- Le SESSION_LIVE.md en tant que log Claude Code
- L'état OpenClaw (WhatsApp/Telegram/agents)
- Un dashboard README.md généré automatiquement depuis l'état réel

---

## PLAN EN 8 ÉTAPES

### Étape 1 — Script `sync-real-state.sh`
Crée un script qui collecte l'état réel de la machine et l'écrit dans `docs/`.
- Lit `SESSION_LIVE.md` → `docs/agents/claude-code/YYYY-MM-DD.md`
- Lit `runner-main.log` (dernières 100 lignes) → `docs/agents/autonomous-runner/`
- Lit `supervisor.log` → `docs/agents/supervisor/`
- Lit `OPUS_QUEUE.md` stats → `docs/agents/memubot/`
- Appelle `openclaw status` → `docs/agents/openclaw/`

### Étape 2 — Dashboard `docs/README.md` auto-généré
Le README.md doit montrer l'état RÉEL, pas du texte statique :
```markdown
# Dashboard — mis à jour YYYY-MM-DD HH:MM

## Agents
| Agent | État | Dernière action | RAM |
| Claude Code | 🟢 ACTIF | [issue/task] | XMB |
| OpenClaw | 🟢 ACTIF | WhatsApp linked | - |
| MemuBot | 🟢 ACTIF | N TODO / M DONE | - |

## Projets Actifs
[tiré de OPUS_QUEUE.md en temps réel]

## Alertes
[erreurs runner, agents morts, etc.]
```

### Étape 3 — Hook dans `claude-auto-loop.sh`
Ajouter en fin de boucle :
```bash
bash ~/Desktop/session_david/scripts/append-log.sh \
  "claude-code" "LOOP_COMPLETE" "$TASK_SUMMARY" "$DURATION"
```

### Étape 4 — Hook dans `autonomous-task-runner.sh`
Après chaque TASK_COMPLETE :
```bash
bash ~/Desktop/session_david/scripts/append-log.sh \
  "autonomous-runner" "TASK_COMPLETE" "$task_title" "${elapsed}s"
```

### Étape 5 — Hook MemuBot (Python)
Dans `~/.memubot/memubot.py`, ajouter dans le `finally:` du runner :
```python
import subprocess
subprocess.Popen(['bash', '/Users/.../scripts/append-log.sh',
  'memubot', 'TASK_DONE', task_summary, duration])
```

### Étape 6 — Hook OpenClaw
Ajouter dans `openclaw.json` → `hooks.internal` → `session-end` :
```json
{ "script": "~/.openclaw/scripts/export-session-log.sh" }
```
(script déjà créé à `~/.openclaw/scripts/export-session-log.sh`)

### Étape 7 — LaunchAgent `sync-real-state` (toutes les 10 min)
- Créer `com.dreamnova.sync-session-david` (10 min)
- Appelle `sync-real-state.sh` → met à jour tous les docs
- Appelle `commit-logs.sh` → push GitHub (debounced)

### Étape 8 — Désactiver auto-deploy Vercel (Ignored Build Step = `exit 1`)
- Aller sur vercel.com → session-david → Settings → Git
- "Ignored Build Step" → `exit 1`
- Comme ça, seul GitHub Actions (06h00 IST) déploie
- Les commits quotidiens n'overloaderont pas Vercel

---

## FICHIERS À CRÉER DEMAIN

```
~/scripts/sync-real-state.sh       ← collecte état réel → docs/
~/scripts/generate-dashboard.sh    ← génère README.md dynamique
```

LaunchAgents à ajouter :
- `com.dreamnova.sync-session-david` (10 min)

Modifications à faire :
- `~/scripts/claude-auto-loop.sh` → ajouter hook append-log
- `~/scripts/autonomous-task-runner.sh` → ajouter hook après TASK_COMPLETE
- `~/.memubot/memubot.py` → ajouter finally: block
- `~/.openclaw/openclaw.json` → ajouter session-end hook

---

## RÉSULTAT ATTENDU

Site `session-david.vercel.app` montrera :
- État en temps quasi-réel (lag max 10 min)
- Tous les agents avec leurs vraies actions
- Dashboard avec TODO/DONE counts, alertes, projets
- Searchable via Docsify (Ctrl+K)
- Opus 4.6 (ou toute IA) peut lire ce site et savoir exactement où on en est

---

## ÉTAT À LA FIN DE CETTE SESSION

**Ce qui EST fait :**
- ✅ session_david/ structure créée
- ✅ GitHub repo live (github.com/CodeNoLimits/session-david)
- ✅ Vercel site live (session-david.vercel.app)
- ✅ append-log.sh opérationnel (mkdir lock macOS)
- ✅ commit-logs.sh debounced
- ✅ gen-sidebar.py auto-nav
- ✅ GitHub Actions (Shabbat-aware, 1x/jour)
- ✅ NUCLEUS.md (1763 chars)
- ✅ SESSION_LIVE.md (heartbeat + supervisor)
- ✅ Protection X02 (Claude JAMAIS tué)
- ✅ claude-sonnet-4-6 partout

**Ce qui reste :**
- ⏳ sync-real-state.sh (DEMAIN)
- ⏳ generate-dashboard.sh (DEMAIN)
- ⏳ Hooks agents (DEMAIN)
- ⏳ LaunchAgent 10min (DEMAIN)
- ⏳ Vercel Ignored Build Step (DEMAIN — 2 min sur dashboard)

---

## CODE DE RÉCUPÉRATION
**[NOVA:20260219-0200]** — Reprendre ici demain.
grep "SESSION DAVID" ~/Desktop/session_david/docs/agents/SESSION_DAVID.md
