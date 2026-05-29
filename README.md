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

## Переменные окружения

Все чувствительные данные вынесены в `.env` (файл в `.gitignore`):

```bash
# .env
export TF_VAR_yc_token="<Yandex Cloud OAuth token>"
export TF_VAR_cloud_id="<Cloud ID>"
export TF_VAR_folder_id="<Folder ID>"
export AWS_ACCESS_KEY_ID="<S3 static key ID>"
export AWS_SECRET_ACCESS_KEY="<S3 static secret key>"
```

Перед началом работы:

```bash
source .env
```

Инициализация и развёртывание:

```bash
make tf-init
make tf-plan
make tf-apply
```

Проверка HTTP и HTTPS:

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

## Ansible

Управление конфигурацией и деплой приложения на ВМ через Ansible.

### Предварительная установка коллекций

```bash
make ansible-install
```

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
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --tags docker
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --tags nginx
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml --tags acme
```

### Что делает плейбук

- Устанавливает Docker и Docker SDK для Python (`community.docker`)
- Создаёт директорию `/var/www/acme-challenge` для Let's Encrypt challenge
- Запускает nginx-контейнер с пробросом порта 80 и монтированием ACME-директории

## Команды

| Команда | Описание |
|---|---|
| `make tf-init` | Инициализация Terraform |
| `make tf-plan` | Показать план изменений |
| `make tf-apply` | Применить изменения |
| `make tf-destroy` | Уничтожить инфраструктуру |
| `make tf-output` | Показать outputs (IP-адреса) |
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
