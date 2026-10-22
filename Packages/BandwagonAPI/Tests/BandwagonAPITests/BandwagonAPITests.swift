import Testing
import Foundation
@testable import BandwagonAPI

@Suite("BandwagonAPI Model & Decoding Tests")
struct BandwagonAPITests {

    @Test("Decode BWGServiceInfo successfully")
    func testDecodeServiceInfo() throws {
        let json = """
        {
            "error": 0,
            "vm_type": "kvm",
            "hostname": "bwg-test-node",
            "node_ip": "104.200.1.1",
            "node_alias": "USCA_2",
            "node_location": "USA: Los Angeles",
            "location_ipv6_ready": true,
            "plan": "basic-10g",
            "plan_monthly_data": 1073741824000,
            "monthly_data_multiplier": 1.0,
            "plan_disk": 42949672960,
            "plan_ram": 2147483648,
            "plan_swap": 0,
            "os": "ubuntu-22.04-x86_64",
            "email": "test@example.com",
            "data_counter": 268435456000,
            "data_next_reset": 1727740800,
            "ip_addresses": ["104.200.1.1", "104.200.1.2"],
            "rdns_api_available": true,
            "ptr": {"104.200.1.1": "my.domain.com"},
            "suspended": false,
            "ssh_port": 29812
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let info = try decoder.decode(BWGServiceInfo.self, from: json)

        #expect(info.isSuccess)
        #expect(info.hostname == "bwg-test-node")
        #expect(info.primaryIP == "104.200.1.1")
        #expect(info.sshPort == 29812)
        #expect(info.bandwidthUsedPercentage > 0.24 && info.bandwidthUsedPercentage < 0.26)
        #expect(info.dataResetDate != nil)
    }

    @Test("Decode BWGLiveServiceInfo successfully")
    func testDecodeLiveServiceInfo() throws {
        let json = """
        {
            "error": 0,
            "vm_type": "kvm",
            "load_average": "0.12, 0.05, 0.01",
            "mem_available_bytes": 1500000000,
            "mem_used_bytes": 647483648,
            "swap_total_bytes": 0,
            "swap_available_bytes": 0,
            "swap_used_bytes": 0,
            "disk_total_bytes": 42949672960,
            "disk_used_bytes": 10000000000,
            "disk_available_bytes": 32949672960,
            "ve_status": "running"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let live = try decoder.decode(BWGLiveServiceInfo.self, from: json)

        #expect(live.isSuccess)
        #expect(live.isRunning)
        #expect(live.load1Min == 0.12)
        #expect(live.memoryTotalBytes == 2147483648)
        #expect(live.memoryUsedPercentage > 0.3)
    }

    @Test("Decode real KiwiVM getLiveServiceInfo response successfully")
    func testDecodeRealKiwiVMLiveServiceInfo() throws {
        let json = """
        {
            "error": 0,
            "vm_type": "kvm",
            "hostname": "valued-hops-6.localdomain",
            "node_ip": "104.224.158.187",
            "node_alias": "USCA_6",
            "node_location": "US, California",
            "location_ipv6_ready": true,
            "plan": "basic-20g",
            "plan_monthly_data": 2147483648000,
            "monthly_data_multiplier": 1.0,
            "plan_disk": 21474836480,
            "plan_ram": 1073741824,
            "plan_swap": 268435456,
            "os": "ubuntu-24.04-x86_64",
            "email": "test@example.com",
            "data_counter": 1045860000000,
            "data_next_reset": 1727740800,
            "ip_addresses": ["104.224.158.187"],
            "rdns_api_available": true,
            "ptr": {},
            "suspended": false,
            "ve_status": "Running",
            "ve_mac1": "00:16:3e:11:22:33",
            "ve_used_disk_space_b": 5368709120,
            "ve_disk_quota_gb": 20,
            "is_cpu_throttled": 0,
            "ssh_port": 22,
            "live_hostname": "valued-hops-6.localdomain",
            "load_average": "0.08 0.03 0.01 1/150 12345",
            "mem_available_kb": 786432,
            "swap_total_kb": 262144,
            "swap_available_kb": 262144
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let live = try decoder.decode(BWGLiveServiceInfo.self, from: json)

        #expect(live.isSuccess)
        #expect(live.isRunning)
        #expect(live.load1Min == 0.08)
        #expect(live.load5Min == 0.03)
        #expect(live.load15Min == 0.01)
        #expect(live.memoryTotalBytes == 1073741824)
        #expect(live.memAvailableBytes == Int64(786432 * 1024))
        #expect(live.memUsedBytes == Int64(1073741824 - (786432 * 1024)))
        #expect(live.memoryUsedPercentage == 0.25)
        #expect(live.diskTotalBytes == 21474836480)
        #expect(live.diskUsedBytes == 5368709120)
        #expect(live.diskUsedPercentage == 0.25)
    }

    @Test("Decode BWGServiceInfo with empty array ptr from PHP response")
    func testDecodeServiceInfoWithEmptyArrayPtr() throws {
        let json = """
        {
            "error": 0,
            "vm_type": "kvm",
            "hostname": "bwg-test-node",
            "node_ip": "104.200.1.1",
            "plan_monthly_data": 1073741824000,
            "monthly_data_multiplier": 1,
            "plan_disk": 42949672960,
            "plan_ram": 2147483648,
            "data_counter": 268435456000,
            "ptr": [],
            "suspended": 0
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let info = try decoder.decode(BWGServiceInfo.self, from: json)

        #expect(info.isSuccess)
        #expect(info.ptr?.isEmpty == true)
        #expect(info.suspended == false)
        #expect(info.monthlyDataMultiplier == 1.0)
    }

    @Test("Decode BWGMigrationLocationsResponse")
    func testDecodeMigrationLocations() throws {
        let json = """
        {
            "error": 0,
            "currentLocation": "USCA_2",
            "locations": ["USCA_2", "HKHK_1"],
            "descriptions": {
                "USCA_2": "USA: Los Angeles [USCA_2]",
                "HKHK_1": "Hong Kong [HKHK_1]"
            }
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let resp = try decoder.decode(BWGMigrationLocationsResponse.self, from: json)

        #expect(resp.isSuccess)
        #expect(resp.locationItems.count == 2)
        #expect(resp.locationItems[0].isCurrent == true)
        #expect(resp.locationItems[1].isCurrent == false)
    }

    @Test("Decode API error")
    func testDecodeAPIError() throws {
        let json = """
        {
            "error": 700001,
            "message": "Invalid VEID or API key"
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        let base = try decoder.decode(BWGAPIResponse.self, from: json)

        #expect(!base.isSuccess)
        #expect(base.error == 700001)
        #expect(base.message == "Invalid VEID or API key")
    }
}
