#!/bin/bash\n\
service ssh start\n\
# --auth none 方便测试，生产环境建议设置密码\n\
# --bind-addr 0.0.0.0:8080 允许外部访问\n\
su - dev -c "code-server --bind-addr 0.0.0.0:8080 --auth none