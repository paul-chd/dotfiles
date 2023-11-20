const DiscordRPC = require('discord-rpc');
const neovim = require('neovim'); // You may need to use a different library or approach to communicate with Neovim.

const clientId = '1174314478263869440'; // Replace with your Discord Application's Client ID

DiscordRPC.register(clientId);

const rpc = new DiscordRPC.Client({ transport: 'ipc' });

rpc.on('ready', () => {
  console.log('Connected to Discord');
});

rpc.login({ clientId }).catch(console.error);

// Function to update Discord presence
async function updatePresence() {
  try {
    const currentFile = await neovim.call('expand', ['%:p']);
    rpc.setActivity({
      details: `Editing ${require('path').basename(currentFile)}`,
      state: 'In Neovim',
    });
  } catch (error) {
    console.error('Error updating Discord presence:', error);
  }
}

// You need a way to call updatePresence on Neovim events.
// For simplicity, you can manually trigger it with a key mapping in Neovim.
