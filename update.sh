#!/bin/bash

#==============================================================================
# Config
#==============================================================================
base_ui_dir="/opt/sajaya/sajaya-ui/src/app/main/pages/"
base_back_dir="/opt/sajaya/sajaya-framework/runtime/component/"
base_git_url="https://gitlab.sajayanegar.ir/sajaya"
base_front=("/opt/sajaya/sajaya-ui/")
base_back=("/opt/sajaya/sajaya-framework/")
#==============================================================================
# Projects list
#==============================================================================
declare -a ui_repos
ui_repos=(
  "organizationalexcellence"
  "emplorder"
  "questionnaire"
  "payroll"
  "workeffort"
  "filesManagement"
  "survey"
  "functionalManagement"
  "casemanagement"
  "training"
  "welfareservicesmodule"
  "humanresourcesplanning"
  "suggestion"
  "operationalreport"
  "goals"
)

declare -a back_repos
back_repos=(
  "sjy-organizationalexcellence"
  "sjy-payroll"
  "sjy-casemanagement"
  "sjy-functionalmanagement"
  "sjy-emplorder"
  "sjy-filemanagement"
  "sjy-survey"
  "sjy-training"
  "sjy-questionnaire"
  "sjy-suggestion"
  "sjy-operationalreport"
  "sjy-workeffort"
  "sjy-humanresourceplanning"
  "sjy-welfare"
)
#==============================================================================
# Functions
#==============================================================================
function pull_clone_backend()
{
  if [ -d "$base_back" ]; then
			git config --global credential.helper store
			echo "##############################################"
			echo "Pulling => $base_back"
			echo "----------------------------------------------"
			cd $base_back
			git pull origin master --no-rebase
			echo "##############################################"
			echo ""
		else
			echo "##############################################"
			echo "Cloning => $base_back"
			echo "----------------------------------------------"
			cd $base_back
			git clone "$base_git_url"/sajaya-framework.git
			echo "##############################################"
			echo ""
  fi
   
	for project in "${back_repos[@]}" ; do 
		if [ -d "$base_back_dir$project" ]; then
			echo "##############################################"
			echo "Pulling => $base_back_dir$project"
			echo "----------------------------------------------"
			cd $base_back_dir$project
			git pull --no-rebase
			echo "##############################################"
			echo ""
		else
			echo "##############################################"
			echo "Cloning => $base_back_dir$project"
			echo "----------------------------------------------"
			cd $base_back_dir
			git clone "$base_git_url"/$project.git
			echo "##############################################"
			echo ""
		fi
	done
}

function pull_clone_frontend()
{
  if [ -d "$base_front" ]; then
			git config --global credential.helper store
			echo "##############################################"
			echo "Pulling => $base_front"
			echo "----------------------------------------------"
			cd $base_front
			git pull origin master --no-rebase
			echo "##############################################"
			echo ""
		else
			echo "##############################################"
			echo "Cloning => $base_front"
			echo "----------------------------------------------"
			cd $base_front
			git clone "$base_git_url"/sajaya-ui.git
			echo "##############################################"
			echo ""
  fi
	for front in "${ui_repos[@]}" ; do 
		if [ -d "$base_ui_dir$front" ]; then
			echo "##############################################"
			echo "Pulling => $base_ui_dir$front"
			echo "----------------------------------------------"
			cd $base_ui_dir$front
			git pull origin master --no-rebase
			echo "##############################################"
			echo ""
		else
			echo "##############################################"
			echo "Cloning => $base_ui_dir$front"
			echo "----------------------------------------------"
			cd $base_ui_dir
			git clone "$base_git_url"/$front.git
			echo "##############################################"
			echo ""
		fi
	done
}

function load_seed_data()
{
  cd $base_back
#  java -jar moqui.war load types=seed,seed-initial
  rm -f "$base_back"runtime/log/* "$base_back"runtime/txlog/*
  bash gradlew load
  cd "$base_back"docker/
  bash compose-down.sh docker-compose.yml
  bash compose-up.sh docker-compose.yml
<<//
    cd $base_back
    bash gradlew load
    rm -rf /opt/backend/webapps/ROOT/old-runtime/
    mv -f /opt/backend/webapps/ROOT/runtime /opt/backend/webapps/ROOT/old-runtime
    rm -rf /opt/backend/webapps/ROOT/runtime
    cp -rf "$base_back"runtime /opt/backend/webapps/ROOT/
    chown -R Swebuser:Swebuser /opt/backend/
    systemctl restart sajaya
//
}
function build_ui()
{
  cd $base_front
  npm run build
  rm -rf /opt/web/*
  cp -rf "$base_front"build/* /opt/web/
}
#==============================================================================
# RUN SCRIPT
#==============================================================================
mode=$1
if [ -z "$1" ]; then
	echo ""
	echo "########################################################"
  echo "# Warning: no specific update set for update service.  #"
	echo "# for Update BACKEND Modules : ./update back           #"
	echo "# for Update FRONTEND Modules : ./update front         #"
	echo "# for Update All Modules : ./update all                #"
	echo "# for Load Seed Data (gradlew load run): ./update load #"
	echo "########################################################"
	echo ""
elif [ "$mode" == "back" ] ; then
  pull_clone_backend
elif [ "$mode" == "front" ] ; then
  pull_clone_frontend
elif [ "$mode" == "all" ] ; then
  pull_clone_backend
  pull_clone_frontend
elif [ "$mode" == "load" ] ; then
  load_seed_data
fi

echo -e "\n############### UPDATE DONE ##################\n"
echo -e "Updated at => $(date)\n"
