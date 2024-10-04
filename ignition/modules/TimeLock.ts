import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MicjohnModule = buildModule("MicjohnModule", (m) => {

    const lockingTime = m.contract("TimeLock");

    return { lockingTime };
});

export default MicjohnModule;