import * as fs from 'fs';
import * as path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

export class ConfigHelper {
  location: string;
  config: Record<string, unknown>;

  constructor() {
    this.location = path.join(__dirname, '../', 'config', 'config.json');
    this.config = this.load();
  }

  /**
   * Load config from file.
   *
   * @returns {Record<string, unknown>}
   */
  load() {
    // Return config if exists
    if (fs.existsSync(this.location)) {
      const raw = fs.readFileSync(this.location, 'utf-8');

      return JSON.parse(raw);
    }
    // Create if not

    const config = {};

    // Create config folder if not exists
    if (!fs.existsSync(this.location)) {
      fs.mkdirSync(path.normalize(`${this.location}/../`), { recursive: true });
    }

    fs.writeFileSync(this.location, JSON.stringify(config, null, 4));

    return config;
  }

  /**
   * Get value from config.
   *
   * @param {string | string[]} keys
   * @param {string} def
   * @returns {any}
   */
  get(keys: string | string[], def?: string) {
    // Refresh config
    this.config = this.load();

    // Convert keys to array if not already
    const keysArr = Array.isArray(keys) ? keys : [keys];

    // Set starting node
    let node = this.config;

    // Loop over all keys
    for (let i = 0; i < keysArr.length; i += 1) {
      const key = keysArr[i];

      // Return value for last key in keys if exists
      if (Object.prototype.hasOwnProperty.call(node, key)) {
        if (i === keysArr.length - 1) {
          return node[key];
        }
      }
      // If any key does not exist, leave loop
      else {
        break;
      }

      // Update current node
      node = node[key] as Record<string, unknown>;
    }

    // Value not found, return default
    return def;
  }

  /**
   * Set config value.
   *
   * @param {array|string} keys
   * @param {mixed} value
   */
  set(keys: string | string[], value: string | number | boolean) {
    // Refresh config
    this.config = this.load();

    // Convert keys to array if not already
    const keysArr = Array.isArray(keys) ? keys : [keys];

    // Set starting node
    let node = this.config;

    // Loop over all keys
    for (let i = 0; i < keysArr.length; i += 1) {
      const key = keysArr[i];

      // If last key in keys and key exists
      if (Object.prototype.hasOwnProperty.call(node, key)) {
        if (i === keysArr.length - 1) {
          node[key] = value;
        }
      } else {
        node[key] = i === keysArr.length - 1 ? value : {};
      }

      // Update current node
      node = node[key] as Record<string, unknown>;
    }

    // Save config
    this.save();
  }

  /**
   * Remove key from config.
   *
   * @param {array|string} keys
   * @returns {boolean}
   */
  remove(keys: string | string[]) {
    // Convert keys to array if not already
    const keysArr = Array.isArray(keys) ? keys : [keys];

    // Set starting node
    let node = this.config;

    for (let i = 0; i < keysArr.length; i += 1) {
      const key = keysArr[i];

      if (Object.prototype.hasOwnProperty.call(node, key)) {
        if (i === keysArr.length - 1) {
          delete node[key];

          // Save updated config
          this.save();
        }
      } else {
        break;
      }

      // Update current node
      node = node[key] as Record<string, unknown>;
    }

    return false;
  }

  /**
   * Write config to file.
   */
  save() {
    fs.writeFileSync(this.location, JSON.stringify(this.config, null, 4));
  }
}

