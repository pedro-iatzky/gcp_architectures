## Deploying onto *google appengine*

### Using the convenience script

**Attention: This script is still in development, so it should be used carefully. 
It is recommended to perform the step by step deployment in case of doubt**

Just execute the script **deploy_on_gae.sh**

```bash
<your_repo_path>/deploy/deploy_on_gae.sh 
```

You can additionally specify the following options:

* [output_folder]: If no output_folder is specified, the deployment package will be
  created in the current working directory 
* [-https]: Use this option if you want to connect to bitbucket using https instead of
  ssh
* [-pm]: Use this option with an argument, where the argument is the name of your 
  application python package (the main module with an \_\_init\_\_.py file in your repo).
  If this option is not specified, the script will look for a folder with the same name
  as the repository
  
  
Take into account that in the *fp_requirements.txt* file are specified the proprietary
 (first-party) dependencies, if there were any.
 
The format is the following:

| **repository_name**  |  **commit (or version tag)** | **python_module_name** |
| ---------------------|------------------------------|------------------------|
| my_clever_repo_name | v0.7.3          | my_package_has_the_same_name_as_my_repo|

### Performing the deployment step by step

Create a new temporal folder (for example):

```bash
mkdir ~/Desktop/gae_deployment
```

Copy the app.yaml and the requirements.txt files into this folder:
 
 ```bash
cp  <your_repo_path>/deploy/app.yaml ~/Desktop/gae_deployment
cp  <your_repo_path>/deploy/requirements.txt ~/Desktop/gae_deployment
```

For deploying the docker onto the Google GAE, you need to change the app.yaml to: 

```
runtime: custom
```


**\*Note:** For further details about the app.yaml configuration, visit
[**app.yaml reference**](https://cloud.google.com/appengine/docs/flexible/python/reference/app-yaml)
 
 
 Then, copy the Dockerfile

 
  ```bash
cp  <your_repo_path>/deploy/Dockerfile ~/Desktop/gae_deployment
```
 
 
Copy your repo **python package** into this folder:

```bash
cp  <your_repo_path>/<python_package> ~/Desktop/gae_deployment
```

Copy the proprietary dependencies into this folder:


```bash
cp  <your_dependency_repo>/<python_package> ~/Desktop/gae_deployment
```
 
In order to deploy on GAE, change directory to the deployment folder
and execute the line:

```bash
gcloud app deploy --promote --stop-previous-version
```

 
If you want to review the **logs** of the application
 
```bash
gcloud app logs tail -s your_service_name
```


## Tuning the application

In order to allow the app deployed in production to work as efficient as possible,
we can set a configuration file for the gunicorn server

Refer to the documentation in:

[Designing your app](http://docs.gunicorn.org/en/latest/design.html)

[Gunicorn settings](http://docs.gunicorn.org/en/latest/settings.html)