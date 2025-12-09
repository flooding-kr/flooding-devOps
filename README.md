# flooding-devOps

<img width="847" height="552" alt="스크린샷 2025-09-15 오전 9 20 57" src="https://github.com/user-attachments/assets/9e6630cf-0e0b-4bcc-af85-fdba64a7f9c1" />

# flooding AWS 인프라 아키텍처

본 레포지토리는 Vercel 기반 프론트엔드와 AWS 기반 백엔드 인프라를 포함한 전체 CI/CD 및 배포 구조를 설명합니다.

아키텍처는 **AWS VPC, EC2 Auto Scaling, ALB, NAT/Bastion, RDS(Postgres), Valkey, CloudWatch, CodeDeploy, EventBridge, Lambda, Grafana** 등을 포함하고 있으며,

프론트엔드는 **Vercel → GitHub 자동 배포**로 구성되어 있습니다.

---

## 전체 아키텍처 개요

본 인프라는 다음과 같은 흐름으로 구성됩니다:

### 1. **Frontend (Client / Vercel)**

- 사용자는 Vercel에 배포된 웹사이트에 접속
- 프론트엔드는 GitHub Push → Vercel 자동 배포
- API 호출 시 AWS ALB를 통해 백엔드로 전달

---

## 2. **Backend (AWS)**

### VPC 구조

- **Public Subnet**
    - Application Load Balancer(ALB)
    - NAT/Bastion 서버(SSH 접근)
- **Private Subnet**
    - Grafana Dashboard(현재 삭제)
    - Jenkins
    - EC2 Server(Auto Scailing)
- **Protected Subnet**
    - Postgres DB
    - Valkey

---

## 3. **컴퓨팅 및 모니터링**

### EC2 Auto Scaling Group

- 백엔드 서버 가동
- CloudWatch 지표 기반 자동 확장/축소
- CodeDeploy Blue/Green 전략으로 무중단 배포

### Grafana

- CloudWatch → 메트릭 수집 → Grafana 시각화

---

## 4. **CI/CD 파이프라인**

### Backend

GitHub → Jenkins → CodeDeploy → Blue/Green 배포

- EventBridge를 통해 배포 이벤트 발생
- Lambda가 Discord Webhook으로 알림 전송

### Frontend

GitHub → Vercel

- Push 시 자동 반영

---

## 5. **스토리지 / 레지스트리**

- **Amazon ECR**: Docker 이미지 저장
- **Amazon S3**: 정적 파일 및 배포 아티팩트 저장

---

## 6. **보안 & 접근**

### Bastion (NAT 겸용)

- DevOps 팀이 SSH로 Private Subnet의 서버 접근
- 모든 서버는 Public IP 없이 Private 환경에서 운영

---

## 📦 기술 스택

| 영역 | 기술 |
| --- | --- |
| Infra | EC2, ASG, Vercel |
| Networking | VPC, ALB, Security Group |
| Database | Postgres, Valkey |
| CI/CD | GitHub, CodeDeploy, EventBridge, Lambda |
| Monitoring | CloudWatch, Grafana |
| Frontend | Vercel |
| Storage | S3, ECR |
| Notification | Discord Webhook |

---

## 흐름 요약

1. **Frontend 개발자** → GitHub push → Vercel 자동 배포
2. **Backend 개발자** → GitHub push → Jenkins(Build) → AWS CodeDeploy → Blue/Green 배포
3. **배포 완료 시** → EventBridge → Lambda → Discord 알림
4. **사용자(Client)** → Vercel 사이트 접속 → API 요청 → AWS ALB → EC2
5. **운영팀(DevOps)** → Bastion 통해 Private 서버 SSH 접근
6. **CloudWatch** → Grafana에 지표 제공 → 모니터링
