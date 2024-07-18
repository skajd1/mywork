# mywork

## InfraStructure Repository

[mywork-api-server](https://github.com/skajd1/mywork-api-server) 이 레포를 clone 받아 dockerizing 후, 테스트할 수 있습니다.

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
DB와 API서버만 파드로 간단하게 배포하였습니다.
```
$ kubectl get all
NAME                                   READY   STATUS    RESTARTS      AGE
pod/mysql-5f978c84b8-dq5v4             1/1     Running   0             28m
pod/spring-boot-app-7fb56979b4-84gz2   1/1     Running   2 (28m ago)   28m

NAME                          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/kubernetes            ClusterIP   10.96.0.1        <none>        443/TCP          47h
service/mysql-service         ClusterIP   10.106.181.108   <none>        3306/TCP         28m
service/spring-boot-service   NodePort    10.107.214.26    <none>        8080:30007/TCP   28m

NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mysql             1/1     1            1           28m
deployment.apps/spring-boot-app   1/1     1            1           28m

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/mysql-5f978c84b8             1         1         1       28m
replicaset.apps/spring-boot-app-7fb56979b4   1         1         1       28m
```

![infrastructure](https://github.com/user-attachments/assets/473e062d-6171-4387-bd4d-5f261d990716)



