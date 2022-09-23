ARG python_version

FROM joyzoursky/python-chromedriver:${python_version} as dev
# FROM python:${python_version} as dev
  ARG USERNAME=worker 

  RUN pip install --upgrade pip
  RUN apk add libgcc libstdc++ shadow

  WORKDIR /usr/src/app

  # Create the user
  RUN adduser -S -D -G root -h /home/$USERNAME -s /bin/sh $USERNAME \
    #
    # [Optional] Add sudo support. Omit if you don't need to install software after connecting.
    && apk add --update sudo shadow \
    # alpine-zsh-config \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && chown $USERNAME:root -R /home/$USERNAME/
  
  # install zsh
  RUN su -c "wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh > zsh-in-docker.sh" - $USERNAME
  RUN su -c "sh zsh-in-docker.sh -t agnostic" - $USERNAME
  RUN su -c "rm zsh-in-docker.sh" - $USERNAME
  
  RUN touch /home/$USERNAME/.zshrc
  RUN sed -i '/^ZSH_THEME/c\ZSH_THEME="agnoster"' /home/$USERNAME/.zshrc 

  RUN usermod -s /bin/zsh $USERNAME

  # ADD --chown=worker:worker Python/requirements.txt .
  # RUN pip install -r requeriments.txt

  RUN chown $USERNAME:root -R /usr/src/app

  # RUN npm install -g nodemon
  RUN pip install pipenv
  # RUN pipenv shell
  RUN su -c "pipenv install" - $USERNAME

  # CMD pipenv run start ; tail -f /dev/null
  CMD su -c "pipenv run start" - $USERNAME ; tail -f /dev/null
