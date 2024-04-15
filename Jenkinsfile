pipeline {
    agent any

    parameters {
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
        choice(name: 'action', choices: ['apply', 'destroy'], description: 'Select the action to perform')
        string(name: 'instance_sg_name', defaultValue: 'ec2-sg', description: 'sg name')
        string(name: 'ami', defaultValue: 'ami-09298640a92b2d12c', description: 'ami here')
        string(name: 'instance_type', defaultValue: 't2.micro', description: 'instance type')
        string(name: 'key_pair', defaultValue: 'jenkins-test-server2-keypair', description: 'key pair ')
        string(name: 'vpcid', defaultValue: 'vpc-0612b4cdd72608697', description: 'vpc id here')
        string(name: 'subnetid', defaultValue: 'subnet-0924996dc843af1b3', description: 'subnet id here')
    }

    environment {
        AWS_ACCESS_KEY_ID     = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_DEFAULT_REGION    = 'ap-south-1'
    }

    stages {
        stage('Instance Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/juleshkumar/jenkins-ec2.git'
            }
        }

        stage('Terraform Apply Stage 2') {
            steps {
                script {
                    sh 'terraform init'
                    sh "terraform plan -out tfplan \
                            -var 'instance_sg_name=${params.instance_sg_name}' \
                            -var 'ami=${params.ami}' \
                            -var 'vpc_id=${params.vpcid}' \
                            -var 'instance_type=${params.instance_type}' \
                            -var 'subnet_id=${params.subnetid}' \
                            -var 'key_pair=${params.key_pair}'"
                    sh 'terraform show -no-color tfplan > tfplan.txt'
                        script {
                    if (params.action == 'apply') {
                        if (!params.autoApprove) {
                            def plan = readFile 'tfplan.txt'
                            input message: "Do you want to apply the plan?",
                            parameters: [text(name: 'Plan', description: 'Please review the plan', defaultValue: plan)]
                        }

                        sh "terraform ${params.action} -input=false tfplan"
                    } else if (params.action == 'destroy') {
                        sh "terraform ${params.action} --auto-approve \
                                -var 'instance_sg_name=${params.instance_sg_name}' \
                                -var 'ami=${params.ami}' \
                                -var 'vpc_id=${params.vpcid}' \
                                -var 'instance_type=${params.instance_type}' \
                                -var 'subnet_id=${params.subnetid}' \
                                -var 'key_pair=${params.key_pair}'"
                                
                    } else {
                        error "Invalid action selected. Please choose either 'apply' or 'destroy'."
                    }

            }
                }
            }
        }
    }
}
