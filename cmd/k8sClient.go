package cmd

import (
	"context"
	"log"
	"os"

	v1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/util/retry"
)

var secretName = os.Getenv("OUTPUT_SECRET")

func HandleSecretUpdate(output []byte) { // All Errors are Fatal
	clientSet := getClient()
	secret := getSecret(clientSet)
	updateSecret(clientSet, secret, output)
}

func getClient() *kubernetes.Clientset {
	config, err := rest.InClusterConfig()
	if err != nil {
		log.Fatalf("Error getting in-cluster config: %v\n", err)
	}

	clientSet, err := kubernetes.NewForConfig(config)
	if err != nil {
		log.Fatalf("Error creating Kubernetes client: %v\n", err)
	}

	return clientSet
}

func getNamespace() string {
	secretNamespaceBytes, err := os.ReadFile("/var/run/secrets/kubernetes.io/serviceaccount/namespace")
	if err != nil {
		log.Fatalf("Error getting namespace: %v\n", err)
	}
	return string(secretNamespaceBytes)

}

func getSecret(clientSet *kubernetes.Clientset) *v1.Secret {
	secretNamespace := getNamespace()
	secret, err := clientSet.CoreV1().Secrets(secretNamespace).Get(context.Background(), secretName, metav1.GetOptions{})
	if err != nil {
		log.Fatalf("Error getting secret: %v\n", err)
	}
	return secret
}

func updateSecret(clientSet *kubernetes.Clientset, secret *v1.Secret, output []byte) {

	secretNamespace := getNamespace()

	secret.Data["output.json"] = output

	err := retry.RetryOnConflict(retry.DefaultBackoff, func() error {
		_, updateErr := clientSet.CoreV1().Secrets(secretNamespace).Update(context.Background(), secret, metav1.UpdateOptions{})
		return updateErr
	})
	if err != nil {
		log.Fatalf("failed to update secret: %v", err)
	}
}
