The template structure:
```
.devpanel/              Reserved
|-dumps/                (optional)
|--db.sql.tgz           Database dump (optional)
|--files.tgz            Static files dump (optional)
|-.drone.yml            CI/CD - Created during app creation process (optional)
|-config.yml            K8S Pod Template
|-init.sh               Creates application from scratch
|-re-init.sh            Clones application
```