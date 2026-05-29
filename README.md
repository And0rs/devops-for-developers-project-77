### Hexlet tests and linter status:
[![Actions Status](https://github.com/And0rs/devops-for-developers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/And0rs/devops-for-developers-project-77/actions)

# DevOps for Developers — Project 77

## Инфраструктура

Проект разворачивает инфраструктуру в Yandex Cloud:

- 2 виртуальные машины (Ubuntu 24.04) с nginx в Docker
- Application Load Balancer с HTTP (80) и HTTPS (443) листенерами
- Домен: [https://percacaosu.online](https://percacaosu.online)
- TLS-сертификат Let's Encrypt для домена
- Удалённое хранение Terraform state в Object Storage

## Требования

- **Terraform** >= 1.0
- **Ansible** >= 2.14
- **Make**
- **Python3** с pip
- **curl**

## Переменные окружения

Все чувствительные данные вынесены в `.env` (файл в `.gitignore`).
Скопируйте `.env.example` в `.env` и заполните:

```bash
cp .env.example .env
# отредактируйте .env, вставив свои ключи
```

Обязательные переменные:

| Переменная | Описание |
|---|---|
| `TF_VAR_yc_token` | OAuth-токен Yandex Cloud |
| `TF_VAR_cloud_id` | ID облака |
| `TF_VAR_folder_id` | ID каталога |
| `AWS_ACCESS_KEY_ID` | Static key ID для Object Storage |
| `AWS_SECRET_ACCESS_KEY` | Static secret key для Object Storage |
| `TF_VAR_datadog_api_key` | API-ключ Datadog (EU) |
| `TF_VAR_datadog_app_key` | APP-ключ Datadog (EU) |

Перед началом работы:

```bash
source .env
```

## Полный цикл развёртывания

```bash
source .env                 # экспорт переменных
make tf-init                # инициализация Terraform (первый раз)
make tf-plan                # просмотр плана
make tf-apply               # создание инфраструктуры
make tf-to-ansible          # генерация Ansible-переменных из Terraform
make ansible-playbook       # деплой приложения на ВМ
```

Проверка:

```bash
make tf-output
curl -I https://percacaosu.online
```

Удаление:

```bash
make tf-destroy
```

## Let's Encrypt

Сертификат получен через `acme.sh` на VM-1 через HTTP-01 challenge.
Приложение доступно по домену: [https://percacaosu.online](https://percacaosu.online)

### Перевыпуск сертификата

```bash
# на VM-1
acme.sh --issue -d percacaosu.online --webroot /var/www/acme-challenge
# после выпуска — скопировать fullchain.pem, privkey.pem, chain.pem в certs/
# и выполнить terraform apply
```

## Ansible

Управление конфигурацией и деплой приложения на ВМ через Ansible.

### Предварительная установка коллекций

```bash
make ansible-install
```

### Генерация переменных из Terraform

```bash
make tf-to-ansible
```

Создаёт `ansible/group_vars/tf_vars.yml` с IP-адресами ВМ, ALB и доменом.

### Проверка доступности ВМ

```bash
make ansible-ping
```

### Деплой

```bash
make ansible-playbook   # полный прогон
make ansible-check      # dry-run (проверить, что изменится)
```

Запуск только определённой группы задач:

```bash
make ansible-playbook ANSIBLE_ARGS="--tags docker"
ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --tags nginx
ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --tags acme
ANSIBLE_CONFIG=ansible/ansible.cfg ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --tags upmon
```

### Просмотр и редактирование зашифрованных переменных

```bash
ansible-vault view ansible/vars/vault.yml
ansible-vault edit ansible/vars/vault.yml
```

Пароль хранится в `vault-password` (в `.gitignore`).

### Что делает плейбук

1. Подгружает зашифрованные переменные (vault) и переменные из Terraform (tf_vars)
2. Устанавливает Datadog Agent на обе ВМ
3. Устанавливает Docker и Docker SDK для Python
4. Создаёт директорию `/var/www/acme-challenge` для Let's Encrypt challenge
5. Запускает nginx-контейнер с пробросом порта 80
6. Настраивает cron-задачу для heartbeat Upmon

## Команды

| Команда | Описание |
|---|---|
| `make tf-init` | Инициализация Terraform |
| `make tf-plan` | Показать план изменений |
| `make tf-apply` | Применить изменения |
| `make tf-destroy` | Уничтожить инфраструктуру |
| `make tf-output` | Показать outputs (IP-адреса) |
| `make tf-to-ansible` | Сгенерировать Ansible-переменные из Terraform |
| `make ansible-install` | Установить Ansible-коллекции |
| `make ansible-ping` | Проверить доступность ВМ |
| `make ansible-playbook` | Запустить плейбук (деплой) |
| `make ansible-check` | Dry-run плейбука |

## Мониторинг

### Datadog
- На обеих ВМ установлен Datadog Agent (роль `DataDog.datadog`), отправляет метрики в `datadoghq.eu`
- Terraform создаёт `datadog_monitor.app_health` — алерт на HTTP-доступность nginx

### Upmon
- Сервис [Upmon](https://www.upmon.com/) отслеживает доступность серверов через heartbeat
- На каждой ВМ настроен cron (`*/5 * * * *`), который `curl`-ит `https://upmon.net/43131059-2d66-4d83-86aa-52a6f3f10005`
- Если сервер не присылает сигнал в течение заданного интервала — Upmon отправляет уведомление

Запуск только heartbeat-задачи:
```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --tags upmon
```
