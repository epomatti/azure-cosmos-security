package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/data/azcosmos"
	"github.com/joho/godotenv"
)

func main() {
	err := godotenv.Load()
	if err != nil {
		panic(err)
	}

	endpoint := os.Getenv("COSMOS_ENDPOINT")

	credential, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		panic(err)
	}

	clientOptions := azcosmos.ClientOptions{
		EnableContentResponseOnWrite: true,
	}

	client, err := azcosmos.NewClient(endpoint, credential, &clientOptions)
	if err != nil {
		panic(err)
	}

	database, err := client.NewDatabase("sqldb")
	if err != nil {
		panic(err)
	}
	container, err := database.NewContainer("products")
	if err != nil {
		panic(err)
	}

	item := Item{
		Id:        "70b63682-b93a-4c77-aad2-65501347265f",
		Category:  "gear-surf-surfboards",
		Name:      "Yamba Surfboard",
		Quantity:  12,
		Price:     850.00,
		Clearance: false,
	}

	partitionKey := azcosmos.NewPartitionKeyString("gear-surf-surfboards")

	context := context.TODO()

	bytes, err := json.Marshal(item)
	if err != nil {
		panic(err)
	}

	response, err := container.UpsertItem(context, partitionKey, bytes, nil)
	if err != nil {
		panic(err)
	}

	fmt.Println(response.RawResponse.Status)
}

type Item struct {
	Id        string  `json:"id"`
	Category  string  `json:"category"`
	Name      string  `json:"name"`
	Quantity  int     `json:"quantity"`
	Price     float32 `json:"price"`
	Clearance bool    `json:"clearance"`
}
