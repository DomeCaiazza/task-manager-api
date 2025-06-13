# Task Manager API

Un'API RESTful per la gestione dei task, sviluppata con Ruby on Rails, che consente a ciascun utente di gestire le proprie attività in modo autonomo.

## Requisiti

- Docker e Docker Compose
- Postman

## Configurazione dell'Ambiente

### Variabili d'Ambiente

Nella root del progetto copia o sposta il file `.env_sample` in `.env`. Le variabili che contiene sono:

```env
MYSQL_ROOT_PASSWORD=your_root_password # passowrd di root del database
MYSQL_DATABASE_DEV=task_manager_dev # nome del database per l'ambiente di sviluppo
MYSQL_DATABASE_TEST=task_manager_test # nome del database per l'ambiente di test
MYSQL_USER=task_manager # nome dell'utente mysql
MYSQL_PASSWORD=your_password # password dell'utente mysql
MYSQL_HOST_DEV=db-dev # host per l'ambiente di sviluppo
MYSQL_HOST_TEST=db-test # host per l'ambiente di test
MYSQL_PORT=3306 # porta servizio database (nella rete docker)
RAILS_MASTER_KEY="6d93e4e8e4ec7e2d1b4128651a19d619" # Master key per l'applicazione, questa è una chiave di esempio, genera una nuova chiave per ambienti non di test
```

### Installazione con Docker

Al termine di questa procedura, l'applicazione sarà servita in locale al seguente link: http://localhost:3000

1. Clona il repository:
```bash
git clone git@github.com:DomeCaiazza/task-manager-api.git
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
docker-compose exec web-dev bundle exec rails db:create db:migrate
```

5. (Opzionale) Popola il database con dati di esempio:
```bash
docker-compose exec web-dev bundle exec rails db:seed
```

## Esecuzione dei Test

I database di sviluppo e test sono separati, nel docker-compose vengono definiti due servizi distinti, il database di test è montato in RAM per migliorare le prestazioni.

Per eseguire i test:

```bash
docker-compose exec web-dev bundle exec rspec
```

## Documentazione

La documentazione OpenAPI viene generata automaticamente durante l'avvio del container attraverso lo script di entrypoint. È possibile accedere alla documentazione interattiva all'indirizzo:

```
http://localhost:3000/api-docs/index.html
```

Questa documentazione fornisce una descrizione di tutti gli endpoint disponibili, inclusi i parametri richiesti, le risposte attese e gli esempi di utilizzo.

## Struttura dell'API

### Postman
Per testare l'utilizzo di questa applicazione importare nel proprio postman il file `task-manager-api.postman_collection.json`
#### Autenticazione per le chiamate
Nella collection "task-manager-api", è definita la variabile "token" che va popolata con il token di risposta, dopo l'autenticazione, della rotta `/users/tokens/sign_in`


### Endpoints Disponibili

#### Autenticazione
- POST `/users/tokens/sign_in` - Login
- POST `/users/tokens/sign_up` - Registrazione
- POST `/users/tokens/revoke` - Revoca token
- GET `/users/tokens/info` - Info dell'utente

#### Tasks
- GET `/api/v1/users/:user_id/tasks` - Lista dei task
- GET `/api/v1/users/:user_id/tasks/:id` - Dettaglio di un task
- POST `/api/v1/users/:user_id/tasks` - Creazione di un nuovo task
- PUT/PATCH `/api/v1/users/:user_id/tasks/:id` - Aggiornamento di un task
- DELETE `/api/v1/users/:user_id/tasks/:id` - Eliminazione di un task

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
docker-compose exec web-dev bundle exec rails db:migrate
```

- Aprire la console Rails:
```bash
docker-compose exec web-dev bundle exec rails console
```

- Controllare i log di docker compose in tempo reale:
```bash
docker-compose logs -tf
```

- Generare la documentazione open api
```bash
docker-compose exec web-dev rake rswag:specs:swaggerize
```

## Sicurezza

- L'API utilizza Devise API per l'autenticazione
- Tutte le richieste API, tranne la registrazione e il login, richiedono autenticazione
- Le password sono validate con un minimo di 6 caratteri