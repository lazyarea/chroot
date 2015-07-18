!/bin/sh

CHROOT_HOME=/home/chroot
CHROOT_DIR="bin dev home lib64 usr/bin etc/bash_completion.d"
CHROOT_CMD="/usr/bin/git /usr/bin/ls /bin/bash /usr/bin/ssh /usr/bin/ssh-keygen"

#--------------------------------------------------
# install dir
#--------------------------------------------------
if [ -e ${CHROOT_HOME} ]; then
  for i in ${CHROOT_DIR}
  do
    mkdir -p ${CHROOT_HOME}/$i
  done
else
  echo ${CHROOT_HOME}" is exists."
fi

#--------------------------------------------------
# install /etc/git*
#--------------------------------------------------
if [ ! -e "${CHROOT_HOME}/etc/bash_completion.d/git" ]; then
  cp -p /etc/bash_completion.d/git ${CHROOT_HOME}/etc/bash_completion.d/
fi
if [ ! -e "${CHROOT_HOME}/etc/bashrc" ]; then
  cp -p /etc/bashrc ${CHROOT_HOME}/etc/
fi

#--------------------------------------------------
# install dev/{tty,null,urandom}
#--------------------------------------------------
if [ ! -e "${CHROOT_HOME}/dev/tty" ]; then
  mknod -m 666 "${CHROOT_HOME}/dev/tty" c 5 0
fi
if [ ! -e "${CHROOT_HOME}/dev/null" ]; then
  mknod -m 666 "${CHROOT_HOME}/dev/null" c 1 3
fi
if [ ! -e "${CHROOT_HOME}/dev/urandom" ]; then
  mknod -m 666 "${CHROOT_HOME}/dev/urandom" c 1 9
fi

#--------------------------------------------------
# copy require libs64
#--------------------------------------------------
for command in ${CHROOT_CMD} 
do
  echo "----------"${command}
  for i in `ldd ${command} | awk '{print $3}' | grep ^\/lib`
    do
     if [[ "${command}" =~ "/usr/bin/" ]]; then
       echo "cp -a ${command} ${CHROOT_HOME}/usr/bin/"
       cp -a ${command} ${CHROOT_HOME}/usr/bin/
     else
       echo "cp -a ${command} ${CHROOT_HOME}/bin/"
       cp -a ${command} ${CHROOT_HOME}/bin/
     fi

     echo "cp $i ${CHROOT_HOME}/lib64/"
     cp $i ${CHROOT_HOME}/lib64/

  done
done

