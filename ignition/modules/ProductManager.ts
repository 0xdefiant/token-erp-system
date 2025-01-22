import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const ProductManager = buildModule("ProductManager", (m) => {
  
  // Deploy ProductManager contract
  const productManager = m.contract("ProductManager", [], {
  });

  return { productManager };
});

export default ProductManager;