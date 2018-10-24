# CircleCI Conjur Integration Demo

Based on sample nodejs project https://github.com/heroku/node-js-sample

This repo demonstrates how to configure CircleCI pipeline to securely fetch secrets from Conjur.
CircleCI Master is given Conjur identity that can generate Host Factory token and enroll executors containers to Conjur. That executor can then use Summon to retrieve secrets for other steps in the pipeline.



## Preparing the Demo
1. Load Conjur Policy and create host identity for CircleCI. Import Conjur parameters and API key to Project or Context environment variables
See https://circleci.com/docs/2.0/env-vars/#setting-an-environment-variable-in-a-project  
Required Variable:  
- CONJUR_ACCOUNT	
- CONJUR_APPLIANCE_URL		
- CONJUR_CIRCLECI_MASTER_LOGIN		
- CONJUR_CIRCLECI_MASTER_API_KEY  
2. Create Heroku project (You can use Heroku Free tier) and onboard Username/API key into Conjur
3. Clone this repo and create your own on Github or BitBucket. Modify .circleci/setup-heroku.sh to point to your heroku project name e.g. git remote add heroku [your heroku project git]
4. Create CircleCI Project to build from your new repo

After the build job completed, your sample app should now be running at https://your-heroku-app-name.herokuapp.com/

