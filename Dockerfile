# syntax=docker/dockerfile:1

FROM archlinux:latest

ENV USERNAME="vscode" HOME_BASE="/home"
ENV CUSTOM_PKG="go"
ENV EMAIL="your_email@example.com" GIT_NAME="developer" GIT_RSA="GIT_RSA" GIT_RSA_PUB="GIT_RSA_PUB"

# 基础环境
    # 设置科大pacman源
RUN echo "Server = https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch" >> /etc/pacman.d/mirrorlist.ustc &&\
    mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak &&\
    mv /etc/pacman.d/mirrorlist.ustc /etc/pacman.d/mirrorlist &&\
    # 设置科大archlinuxcn源
    echo "[archlinuxcn]" >> /etc/pacman.conf &&\
    echo "SigLevel = Never" >> /etc/pacman.conf &&\
    echo "Server = https://mirrors.ustc.edu.cn/archlinuxcn/\$arch" >> /etc/pacman.conf &&\
    # 更新仓库
    pacman -Syu --noconfirm &&\
    pacman -S --noconfirm archlinuxcn-keyring sudo base-devel inetutils openssh openssl yay zsh vim git supervisor ${CUSTOM_PKG}

# 设置用户
RUN groupadd docker &&\
    useradd -m -s /bin/zsh -b ${HOME_BASE} -G wheel,docker ${USERNAME} &&\
    # 设置用户sudo无密码
    echo "${USERNAME} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${USERNAME} &&\
    # 设置zsh
    chsh -s /bin/zsh ${USERNAME}

# 切换用户
USER ${USERNAME}
# 移动到home目录
WORKDIR ${HOME_BASE}/${USERNAME}
# 初始化
ADD ./install.sh ${HOME_BASE}/${USERNAME}/install.sh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended &&\
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions &&\
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting &&\
    sed -i 's/(git)/(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc &&\
    git config --global user.name ${GIT_NAME} &&\
    git config --global user.email ${EMAIL} &&\
    mkdir ~/.ssh &&\
    echo ${GIT_RSA} > ~/.ssh/id_rsa &&\
    echo ${GIT_RSA_PUB} > ~/.ssh/id_rsa.pub