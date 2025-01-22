import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OrderManager = buildModule("OrderManager", (m) => {
    
    const productManagerAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
  
    // Deploy OrderManager contract
    const orderManager = m.contract("OrderManager", [productManagerAddress], {
    });

    return { orderManager };
});

export default OrderManager;