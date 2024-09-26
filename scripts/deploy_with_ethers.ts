import { deploy } from './ethers-lib'

(async () => {
  try {
    const result = await deploy('BasedGutterCats', ['0x701CA3Dea4c1174a724f9fBCeDCa59104f41Bc15'])
    console.log(`address: ${result.address}`)
  } catch (e) {
    console.log(e.message)
  }
})()