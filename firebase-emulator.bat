echo set environment variables

call set ENVIRONMENT=development

echo Init emulator

call firebase emulators:start --only firestore,storage,auth

pause