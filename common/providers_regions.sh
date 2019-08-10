case  $provider  in
  aws)
     list_region=$list_aws_region
     ;;
  gcp)
     list_region=$list_gcp_region
     ;;
  azure)
     list_region=$list_azure_region
     ;;
  *)
esac
