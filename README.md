# epam_diploma_task
kubctl configuration

aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)