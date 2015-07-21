!/bin/sh

CHROOT_HOME=/home/chroot
CHROOT_DIR="bin dev home lib64 usr/bin etc/bash_completion.d"
CHROOT_CMD="/usr/bin/git /usr/bin/ls /bin/bash"

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
       #echo "cp -a ${command} ${CHROOT_HOME}/usr/bin/"
       cp -a ${command} ${CHROOT_HOME}/usr/bin/
     else
       #echo "cp -a ${command} ${CHROOT_HOME}/bin/"
       cp -a ${command} ${CHROOT_HOME}/bin/
     fi

     echo "cp $i ${CHROOT_HOME}/lib64/"
     cp $i ${CHROOT_HOME}/lib64/

  done
done

#--------------------------------------------------
# usage
#--------------------------------------------------
echo ""
echo "ex) exists user."
echo "mkdir ${CHROOT_HOME}/home/lazyarea"

echo ""
echo "ex) /etc/ssh/sshd_config"
echo "Subsystem       sftp    /usr/libexec/openssh/sftp-server"
echo "Match User lazyarea"
echo "        X11Forwarding no"
echo "        AllowTcpForwarding no"
echo "        ChrootDirectory /home/chroot"

#--------------------------------------------------
# usage
#--------------------------------------------------
echo ""

if [  -e "/bin/rbash" ]; then
  echo "/bin/rbash is already exists."
  exit
fi
echo "ex) user setting"
echo "ln -s /bin/bash /bin/rbash"
echo "echo \"/bin/rbash\" >> /etc/shells"
echo "chown root. /home/lazyarea/.bash_profile"
echo "chmod 755 /home/lazyarea/.bash_profile"
echo "sed -i \"s/export\ PATH/export\ PATH=\/home\/lazyarea\/bin/\" /home/lazyarea/.bash_profile"
