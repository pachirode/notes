# `GitLab`

## 安装步骤

- 安装 `gitlab`

```bash
docker pull gitlab/gitlab-ce:latest
```

- 配置

```bash
# /etc/gitlab/gitlab.rb
vim /sev/gitlab/config/gitlab.rb (gitlab.rb文件内容默认全是注释)
#配置http协议所使用的访问地址，不加端口号默认为80，加端口号根据设置端口号添加,找到
external_url 'http://IP'
#配置ssh协议所使用的访问地址和端口
gitlab_rails['gitlab_ssh_host'] = 'IP'
gitlab_rails['gitlab_shell_ssh_port'] = 222 # 此端口是run时22端口映射的222端口
:wq #保存配置文件并退出
#docker restart gitlab （重启gitlab容器）

sudo chown -R 1000:1000 /data/gitlabs
sudo chmod -R 0755 /data/gitlabs
# 手动初始化脚本
/opt/gitlab/init/postgresql start
```





### Jenkins

- 获取镜像

```bash
docker run \
  --rm \
  -u root \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /data/jenkins:/var/jenkins_home \
  -v /etc/localtime:/etc/localtime \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$HOME":/home \
  jenkins/jenkins:lts-jdk17
```

- 解锁
  - `localhost:8080`
- 安装插件
  - `docker` 里面如果版本与插件不匹配需要手动上传安装插件



```yaml
pipeline {
    agent none
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'python:2-alpine'
                }
            }
            steps {
                sh 'python -m py_compile sources/add2vals.py sources/calc.py'
            }
        }
        stage('Test') {
            agent {
                docker {
                    image 'qnib/pytest'
                }
            }
            steps {
                sh 'py.test --verbose --junit-xml test-reports/results.xml sources/test_calc.py'
            }
            post {
                always {
                    junit 'test-reports/results.xml'
                }
            }
        }
        stage('Deliver') {
            agent {
                docker {
                    image 'minidocks/pyinstaller'
                }
            }
            steps {
                sh 'pyinstaller --onefile sources/add2vals.py'
            }
            post {
                success {
                    archiveArtifacts 'dist/add2vals'
                }
            }
        }
    }
}

```





# docker-compose



```yaml
  1 # DevOP docker compose yaml
  2
  3 services:
  4   jenkins:
  5     restart: always
  6     image: jenkins/jenkins:test
  7     container_name: jenkins
  8     hostname: jenkins
  9     ports:
 10       - 8010:8080
 11       - 8011:50000
 12     volumes:
 13       - /data/jenkins:/var/jenkins_home
 14       - /etc/localtime:/etc/localtime
 15       - /var/run/docker.sock:/var/run/docker.sock
 16       - /usr/bin/docker:/usr/bin/docker
 17
 18   gitlab:
 19     restart: always
 20     image: gitlab/gitlab-ce:test
 21     container_name: gitlab
 22     hostname: gitlab
 23     environment:
 24       GITLAB_OMNIBUS_CONFIG: |
 25         external_url 'http://IP:30080'
 26         gitlab_rails['log_level'] = "info"
 27         gitlab_rails['log_directory'] = "/var/log/gitlab/gitlab-rails"
 28     ports:
 29       - 30080:30080
 30       - 30022:22
 31       - 30443:443
 32     volumes:
 33       - /data/gitlabs/config:/etc/gitlab
 34       - /data/gitlabs/logs:/var/log/gitlab
 35       - /data/gitlabs/data:/var/opt/gitlab
 36       - /etc/localtime:/etc/localtime
 37     shm_size: 256m
 38     privileged: true

```



# Portainer

```bash
docker pull portainer/portainer-ce
```

