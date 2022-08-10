
import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import ExampleNFT from "../contracts/ExampleNFT.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"
import FungibleToken from "../contracts/FungibleToken.cdc"

transaction(

    name: String ,
    description: String,
    thumbnail: String,

) {
  let recipientRef: &{NonFungibleToken.CollectionPublic}
  let minterRef: &ExampleNFT.NFTMinter
  

    prepare(signer: AuthAccount) {
       
        if signer.borrow<&ExampleNFT.Collection>(from: ExampleNFT.CollectionStoragePath) == nil {
            // Create a new empty collection
           let collection <- ExampleNFT.createEmptyCollection()

           // save it to the account
           signer.save(<-collection, to: ExampleNFT.CollectionStoragePath)

          // create a public capability for the collection
          signer.link<&{NonFungibleToken.CollectionPublic, ExampleNFT.ExampleNFTCollectionPublic, MetadataViews.ResolverCollection}>(
              ExampleNFT.CollectionPublicPath,
              target: ExampleNFT.CollectionStoragePath
          )
        }

         // Create a new empty collection
        let minter <- ExampleNFT.createNFTMinter()

        // save it to the account
        signer.save(<-minter, to: ExampleNFT.MinterStoragePath)
       
            // display a NFT
       self.recipientRef = signer.getCapability<&{NonFungibleToken.CollectionPublic}>(ExampleNFT.CollectionPublicPath)
            .borrow()
            ?? panic("Could not get receiver reference to the NFT Collection")
      //take a NFT
      self.minterRef = signer.borrow<&ExampleNFT.NFTMinter>(from: ExampleNFT.MinterStoragePath)
          ?? panic("could not borrow minter reference")
    }

    execute {
        var royalties: [MetadataViews.Royalty] = []
        //var recipient: [address]=

        // Mint the NFT 
        self.minterRef.mintNFT(
            recipient: self.recipientRef,
            name: name,
            description: description,
            thumbnail: thumbnail,
            royalties: royalties
        )
        log("hello")

        
    }

}
