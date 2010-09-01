#!/bin/bash

cd /Users/arnaud/GITROOT/GoFigure2

#setup environment :

GITBIN=/opt/local/bin
SVNBIN=$GITBIN
SSHBIN=/usr/bin
#the ssh keys needed for Git connection :
echo `$SSHBIN/ssh-add /Users/arnaud/.ssh`



#update the repository :

echo "  Fetch from svn"
echo `$GITBIN/git svn fetch`
echo `$GITBIN/git svn rebase`


# convert tags branches created by git svn to real git tags
echo "  Convert tag branches to actual git tags"
for GITREF in `$GITBIN/git for-each-ref refs/remotes/tags | cut -d / -f 4-`; do
  echo "dealing with tag $GITREF"
  $GITBIN/git tag -a "$GITREF" -m"delete SVN" "refs/remotes/tags/$GITREF"
  $GITBIN/git push origin ":refs/heads/tags/$GITREF"
  $GITBIN/git push origin tag "$GITREF"
done

echo "  Push svn:trunk to git:develop"
# first push the trunk to develop
echo `$GITBIN/git checkout -b develop trunk`
echo `$GITBIN/git checkout develop`
echo `$GITBIN/git svn fetch`
echo `$GITBIN/git svn rebase`
echo `$GITBIN/git push origin develop`

#then push the branches
## if we wanted to be correctly synchronized :
##for BRANCHES in `$GITBIN/git branch -r | grep -v "@" | grep -v "tag" | grep -v "trunk"`; do
#we list the braches currently present on the svn server :
for SVNBRANCHES in `$SVNBIN/svn list http://gofigure2.svn.sourceforge.net/svnroot/gofigure2/branches | sed 's_\/__'`; do

  #which branch are we dealing with :
  echo "  $SVNBRANCHES : fetching from svn"
  #fetch svn branches
  echo `$GITBIN/git svn fetch`

  # create branches linked to remote tracking branches present on the svn server
  echo "  $SVNBRANCHES : try to create git:feature_$SVNBRANCHES and track git remote tracking branch remotes/$SVNBRANCHES"
  echo `$GITBIN/git checkout -b feature_$SVNBRANCHES $SVNBRANCHES`
  echo `$GITBIN/git checkout feature_$SVNBRANCHES`

  #push the branch to origin (github)
  echo `$GITBIN/git push origin feature_$SVNBRANCHES`
done

