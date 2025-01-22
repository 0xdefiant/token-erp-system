import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const OrderManager = buildModule("OrderManager", (m) => {
    
    const productManagerAddress = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";
  
    // Deploy OrderManager contract
    const orderManager = m.contract("OrderManager", [productManagerAddress], {
    });

    return { orderManager };
});

export default OrderManager;