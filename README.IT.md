# Task Manager API

Un'API RESTful per la gestione dei task, sviluppata con Ruby on Rails, che consente a ciascun utente di gestire le proprie attività in modo autonomo.

## Requisiti

- Docker e Docker Compose
- Postman

## Configurazione dell'Ambiente

### Variabili d'Ambiente

Nella root del progetto copia o sposta il file `.env_sample` in `.env`. Le variabili che contiene sono:

```env
APPLICATION_NAME="task_manager"
MYSQL_HOST_APP="db-app"
MYSQL_HOST_TEST="db-test"

MYSQL_USER="task_manager"
MYSQL_PASSWORD="password"
MYSQL_PORT="3306"
MYSQL_ROOT_PASSWORD="password"

RAILS_ENV="development"

RAILS_MASTER_KEY="6d93e4e8e4ec7e2d1b4128651a19d619" ## this is an example, don't user it in production please see https://rubyonrails.org/docs
SECRET_KEY_BASE="f2e4f2a4bd502d7a74342e95826cd37b72cca93b23bed1330d556bb0e63d0e506c2bbcb17d7f3a653339d93c37ecb2f4e2617b65772ee0e957b50a97d26224ff" ## this is an example, don't user it in production please see https://rubyonrails.org/docs
```

### Installazione con Docker

Al termine di questa procedura, l'applicazione sarà servita in locale al seguente link: http://localhost:3000

1. Clona il repository:
```bash
git clone https://github.com/DomeCaiazza/task-manager-api.git
cd task-manager-api
```

2. Creare il file di variabili d'ambiente `.env` come mostrato sopra

3. Avvia i container Docker:
```bash
docker-compose up --build -d && docker-compose logs -tf
```

4. (Opzionale) In un nuovo terminale, esegui le migrazioni del database:
PS: la creazione e la migrazione del database viene eseguita automaticamente dal file "entrypoint.dev.sh"
```bash
docker-compose exec web-app bundle exec rails db:create db:migrate
```

5. (Opzionale) Popola il database con dati di esempio:
```bash
docker-compose exec web-app bundle exec rails db:seed
```

## Esecuzione dei Test

I database di sviluppo e test sono separati, nel docker-compose vengono definiti due servizi distinti, il database di test è montato in RAM per migliorare le prestazioni.

Per eseguire i test:

```bash
docker-compose exec web-app bundle exec rspec
```

## Documentazione

La documentazione OpenAPI viene generata automaticamente durante l'avvio del container attraverso lo script di entrypoint. È possibile accedere alla documentazione interattiva all'indirizzo:

```
http://localhost:3000/api-docs/index.html
```

Questa documentazione fornisce una descrizione di tutti gli endpoint disponibili, inclusi i parametri richiesti, le risposte attese e gli esempi di utilizzo.

## Struttura dell'API

### Postman
Per testare l'utilizzo di questa applicazione importare nel proprio postman il file https://raw.githubusercontent.com/DomeCaiazza/task-manager-api/refs/heads/main/task-manager-api.postman_collection.json

Le variabili d'ambiente sono definite all'interno della collection.

#### Autenticazione per le chiamate
Nella collection "task-manager-api", è definita la variabile "token" che va popolata con il token di risposta, dopo l'autenticazione, della rotta `/users/tokens/sign_in`


### Endpoints Disponibili

#### Autenticazione
- POST `/users/tokens/sign_in` - Login
- POST `/users/tokens/sign_up` - Registration
- POST `/users/tokens/revoke` - Revoke token
- GET `/users/tokens/info` - User info

#### Tasks
- GET `/api/v1/tasks` - List tasks
- GET `/api/v1/tasks/:id` - Task details
- POST `/api/v1/tasks` - Create a new task
- PUT/PATCH `/api/v1/tasks/:id` - Update a task
- DELETE `/api/v1/tasks/:id` - Delete a task

### Parametri dei Task
- `title` (string, required)
- `description` (text)
- `completed` (boolean)

### Filtri
L'endoint per la lista dei task permette di filtrare i risultati per tutti i suoi parametri, i filtri disponibili sono:
- completed_eq: il completameto è uguale a "true" o "false"
- title_cont: il titolo contiene
- description_cont: la descrizione contiene
- title_or_description_cont: titolo o descrizione contiene

## Sviluppo

### Struttura del Progetto
- `app/controllers/api/v1/` - Controller API
- `app/models/` - Modelli
- `spec/` - Test RSpec

### Comandi Utili

- Avviare il server:
```bash
docker-compose up
```

- Eseguire le migrazioni:
```bash
docker-compose exec web-app bundle exec rails db:migrate
```

- Aprire la console Rails:
```bash
docker-compose exec web-app bundle exec rails console
```

- Controllare i log di docker compose in tempo reale:
```bash
docker-compose logs -tf
```

- Generare la documentazione open api (non funziona in ambiente di produzione)
```bash
docker-compose exec web-app rake rswag:specs:swaggerize
```

## Sicurezza

- L'API utilizza Devise API per l'autenticazione
- Tutte le richieste API, tranne la registrazione e il login, richiedono autenticazione
- Le password sono validate con un minimo di 6 caratteri