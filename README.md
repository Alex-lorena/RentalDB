# Gestão de Imóveis e Agentes — Base de Dados
 
Academic database project for property, agent, and reservation management. Developed for the **Databases** course at Universidade Técnica do Atlântico (UTA), 2025/2026.
 
## Overview
 
A relational database designed to support a real estate rental platform, covering the full lifecycle of properties, agents, clients, and bookings — with built-in integrity rules enforced through triggers and stored procedures.
 
## Database Schema
 
| Table | Description |
|---|---|
| `Administrador` | Platform administrators |
| `Autenticacao` | Authentication actions tied to admins |
| `Coafitriao` | Co-hosts associated with properties |
| `Imovel` | Properties with full details (type, price, rules, etc.) |
| `Imovel_Fotos` | Photos linked to each property |
| `Imovel_Comodidades` | Amenities linked to each property |
| `Agente` | Agents responsible for properties |
| `Cliente` | Clients who make reservations |
| `Reservas` | Bookings between clients and properties |
 
## Features
 
**Triggers**
- `Imovel_Fechado` — blocks reservations on closed properties
- `Valida_Avaliacao_Cliente` — ensures client ratings stay between 0 and 10
**Stored Procedures**
- `Obter_Imoveis_agente(nome)` — lists all properties managed by a given agent
- `Obter_Reservas_Cliente(nome)` — retrieves full reservation history for a client
- `Reservas_Imovel(titulo)` — counts reservations per property grouped by client
**Views**
- `Reservas_Detalhes` — consolidated reservation info with property and client names
- `Avaliacoes_Agente` — agents ranked by rating (descending)
## Setup
 
Requirements: MySQL 8.0+ (or compatible)
 
```bash
mysql -u root -p < PF.sql
```
 
The script will automatically drop and recreate the `PF` database, create all tables, triggers, procedures, views, and insert sample data for testing.
 
## Project Files
 
| File | Description |
|---|---|
| `PF.sql` | Full database script (DDL + DML + sample data) |
| `Dconceitual.drawio` | Conceptual ER diagram |
| `Dlogico.drawio` | Logical ER diagram |
| `Projeto_Final___BD.pdf` | Full project report |
 
## Known Limitations
 
- Passwords are stored in plain text — hashing should be added before any production use
- The bidirectional relationship between `Agente` and `Imovel` introduces some redundancy
- Triggers may affect performance at high data volumes
## Author
 
Alexandre Lorena — Instituto de Engenharias e Ciências do Mar, UTA  
Professor: Jandir Medina
