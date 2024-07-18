# mywork

## InfraStructure Repository

### k8s API 서버 배포
- Environment - Terraform
- Language - Java 17(Spring boot 3)
- Database - MySQL 5.7

**1. 프로젝트 루트 디렉토리에서 다음 명령어를 통해 Terraform을 초기화**
```
terraform init
```

**2. 이후, 해당 명령어로 리소스를 배포**
```
terraform apply
```
**3. minikube 사용 시, NodePort Service 접속을 위해 해당 명령어 실행**
```
minikube service spring-boot-service
```

**4. 리소스 삭제**
```
terraform destroy
```


### project 구조
```
├── README.md
├── main.tf
├── variables.tf
├── modules
│   ├── mysql
│   │   ├── main.tf
│   │   ├── variables.tf
│   └── spring-boot
│       ├── main.tf
│       ├── variables.tf
└── terraform.tfstate
```

### Architecture




