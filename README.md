### Hexlet tests and linter status:
[![Actions Status](https://github.com/And0rs/devops-for-developers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/And0rs/devops-for-developers-project-77/actions)

# DevOps for Developers — Project 77

## Инфраструктура

Проект разворачивает инфраструктуру в Yandex Cloud:

- 2 виртуальные машины (Ubuntu 24.04) с nginx в Docker
- Application Load Balancer с HTTP (80) и HTTPS (443) листенерами
- TLS-сертификат Let's Encrypt (самоподписанный для IP-адреса, действителен 6 дней)
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
curl http://$(make tf-output | grep lb-url | cut -d' ' -f2)
curl -k https://$(make tf-output | grep lb-url-https | cut -d' ' -f2)
```

Удаление:

```bash
make tf-destroy
```

## Let's Encrypt

Сертификат получен через `acme.sh` с профилем `shortlived` (6 дней).
Для обновления выполнить на VM-1:

```bash
export LE_IP=<vm-1-public-ip>
ssh -i key/yc ubuntu@$LE_IP 'sudo ~/.acme.sh/acme.sh --renew -d <ip> --cert-profile shortlived --force'
```

Сертификат импортирован в Yandex Certificate Manager через Terraform.
Файлы сертификата хранятся локально в `certs/`.

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
