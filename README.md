### Hexlet tests and linter status:
[![Actions Status](https://github.com/And0rs/devops-for-developers-project-77/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/And0rs/devops-for-developers-project-77/actions)

# DevOps for Developers — Project 77

## Инфраструктура

Проект разворачивает инфраструктуру в Yandex Cloud:

- 2 виртуальные машины (Ubuntu 24.04) с nginx в Docker
- Application Load Balancer с HTTP-листенером
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

Проверка:

```bash
curl http://$(make tf-output | grep lb-url | cut -d' ' -f2)
```

Удаление:

```bash
make tf-destroy
```

## Команды

| Команда | Описание |
|---|---|
| `make tf-init` | Инициализация Terraform |
| `make tf-plan` | Показать план изменений |
| `make tf-apply` | Применить изменения |
| `make tf-destroy` | Уничтожить инфраструктуру |
| `make tf-output` | Показать outputs (IP-адреса) |
